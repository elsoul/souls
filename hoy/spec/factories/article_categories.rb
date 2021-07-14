FactoryBot.define do
  factory :article_category do
    name { Faker::Books::CultureSeries.culture_ship_class }
    tags { %w[tag1 tag2 tag3] }
    is_deleted { false }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
