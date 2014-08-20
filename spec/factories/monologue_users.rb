# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user, class: Monologue::UserRecord do
    sequence(:name){|n| "test #{n}"}
    sequence(:email){ |n| "test#{n}@example.com"}
    password "password"
  end

  factory :user_with_post, class: Monologue::UserRecord, parent: :user do |user|
    after(:create) { |u| FactoryGirl.create(:post, user: u) }
  end

  factory :orm_user, class: Object do
    repo :user

    sequence(:name){|n| "test #{n}"}
    sequence(:email){ |n| "orm_test#{n}@example.com"}
    password_digest '$2a$10$6xL549QtdvsdZm0Y4Mm47Oygmj5t5vpnaFMNMVXeAPjf7t3nSuiv6' # 'password'
  end

  factory :orm_user_with_post, parent: :user do
    # after(:create) { |u| FactoryGirl.create(:post, user: u) }

    after(:build) do |user|
      user.session.association(user, :posts).add(
        FactoryGirl.build(:orm_post, session: user.session)
      )
    end
  end
end
