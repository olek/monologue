FactoryGirl.define do
  factory :tag, class: Monologue::TagRecord do
    name "Rails"
  end

  factory :orm_tag, class: Object do
    repo :tag

    name "Rails"
  end
end
