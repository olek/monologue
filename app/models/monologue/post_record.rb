class Monologue::PostRecord < ActiveRecord::Base
  self.table_name = 'monologue_posts'

  # keeping polymorphic_url route helper happy
  def self.model_name
    ActiveModel::Name.new(self, Monologue, 'Monologue::Post')
  end

  # Now we need to handle case of partial rendering getting confused
  # with wrong class... love the consistency of rails...
  def to_partial_path
    model_name  = self.class.model_name
    "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
  end

  has_many :taggings, class_name: "Monologue::TaggingRecord", foreign_key: :post_id
  has_many :tags, through: :taggings, dependent: :destroy, order: :tag_id
  before_validation :generate_url
  belongs_to :user, class_name: "Monologue::UserRecord"

  attr_accessible :title, :content, :url, :published, :published_at, :tag_list

  scope :default, order("published_at DESC, monologue_posts.created_at DESC, monologue_posts.updated_at DESC")
  scope :published, lambda { default.where(published: true).where("published_at <= ?", DateTime.now) }

  default_scope includes(:tags)

  validates :user_id, presence: true
  validates :title, :content, :url, :published_at, presence: true
  validates :url, uniqueness: true
  validate :url_do_not_start_with_slash

  def tag_list= tags_attr
    self.tag!(tags_attr.split(","))
  end

  def tag_list
    self.tags.map { |tag| tag.name }.join(", ") if self.tags
  end

  def tag!(tags_attr)
    self.tags = tags_attr.map(&:strip).reject(&:blank?).map do |tag|
      Monologue::TagRecord.find_or_create_by_name(tag)
    end
  end

  def full_url
    "#{Monologue::Engine.routes.url_helpers.root_path}#{self.url}"
  end

  def published_in_future?
    self.published && self.published_at > DateTime.now
  end

  def self.page p
    per_page = Monologue.posts_per_page || 10
    set_total_pages(per_page)
    p = (p.nil? ? 0 : p.to_i - 1)
    offset = p * per_page
    self.limit(per_page).offset(offset)
  end

  def self.total_pages
    @number_of_pages
  end

  def self.set_total_pages per_page
    @number_of_pages = self.count / per_page + (self.count % per_page == 0 ? 0 : 1)
  end

  private

  def generate_url
    return unless self.url.blank?
    year = self.published_at.class == ActiveSupport::TimeWithZone ? self.published_at.year : DateTime.now.year
    self.url = "#{year}/#{self.title.parameterize}"
  end

  def url_do_not_start_with_slash
    errors.add(:url, I18n.t("activerecord.errors.models.monologue/post.attributes.url.start_with_slash")) if self.url.start_with?("/")
  end

end
