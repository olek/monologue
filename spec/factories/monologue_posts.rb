# encoding: UTF-8
FactoryGirl.define do
  factory :post, class: Monologue::PostRecord do
    published true
    association :user, factory: :user
    sequence(:title) { |i| "post title #{i}" }
    content "this is some text with french accents éàöûù and so on...even html tags like <br />"
    sequence(:url) { |i| "post/ulr#{i}" }
    sequence(:published_at) {|i| DateTime.new(2011,1,1,12,0,17) + i.days }
  end

  factory :post_with_tags, parent: :post do
    after(:create) { |p| p.tag!(['Rails', 'a great tag'])}
  end

  factory :unpublished_post, parent: :post do
    published false
    title "unpublished"
    url "unpublished"
  end

  factory :orm_post, class: Object do
    repo :post

    published true
    sequence(:title) { |i| "post title #{i}" }
    content "this is some text with french accents éàöûù and so on...even html tags like <br />"
    sequence(:url) { |i| "post/ulr#{i}" }
    sequence(:published_at) {|i| DateTime.new(2011,1,1,12,0,17) + i.days }

    association :user, factory: :orm_user
  end

  factory :orm_unpublished_post, parent: :orm_post do
    published false
    title "unpublished"
    url "unpublished"
  end

  factory :orm_post_with_tags, parent: :orm_post do
    # after(:create) { |p| p.tag!(['Rails', 'a great tag'])}
    after(:build) do |post|
      post.session.association(post.current, :tags).add(
        FactoryGirl.build(:orm_tag, name: 'Rails', session: post.session),
        FactoryGirl.build(:orm_tag, name: 'a great tag', session: post.session)
      )
    end
  end
end
