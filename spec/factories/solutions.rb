FactoryBot.define do
  factory :solution do
    post { nil }
    solution { "MyText" }
    url { "MyString" }
    association :user
  end
end
