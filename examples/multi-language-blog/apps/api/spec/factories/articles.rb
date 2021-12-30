FactoryBot.define do
  factory :article do
    association :user, factory: :user
    title { "MyString" }
    body { "MyString" }
    category { "MyString" }
    tags { %w[tag1 tag2 tag3] }
    slug { "MyString" }
    published { false }
    is_deleted { false }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
