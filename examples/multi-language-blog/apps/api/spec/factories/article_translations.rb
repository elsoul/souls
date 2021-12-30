FactoryBot.define do
  factory :article_translation do
    association :article, factory: :article
    title { "MyString" }
    body { "MyString" }
    is_deleted { false }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
