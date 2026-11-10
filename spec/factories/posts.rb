FactoryBot.define do
  factory :post do
    association :user
    title { "MyString" }
    content { "MyText" }
    date { "2026-11-02" }
    status { 1 }
  end
end
