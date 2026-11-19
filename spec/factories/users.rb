FactoryBot.define do
  factory :user do
    username { "テストユーザー" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "1234567" }
  end
end
