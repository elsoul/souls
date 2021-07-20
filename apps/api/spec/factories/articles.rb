FactoryBot.define do
  factory :article do
    association :user, factory: :user
    title { Faker::Book.unique.title }
    body { Faker::Quote.matz }
    thumnail_url { Faker::Internet.url }
    public_date { Time.now }
    association :article_category, factory: :article_category
    is_public { false }
    just_created { false }
    slag { Faker::Internet.password(min_length: 16) }
    tags { %w[tag1 tag2 tag3] }
    is_deleted { false }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
