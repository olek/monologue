# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user, class: Monologue::UserRecord do
    sequence(:name){|n| "test #{n}"}
    sequence(:email){ |n| "test#{n}@example.com"}
    password "password"
  end

  factory :user_with_post, class: Monologue::UserRecord, parent: :user do |user|
    #after(:create) do |user, evaluator|
    #  create_list(:post, 1, user: user)
    #end
    after(:create) { |u| FactoryGirl.create(:post, user: u) }
  end
end
