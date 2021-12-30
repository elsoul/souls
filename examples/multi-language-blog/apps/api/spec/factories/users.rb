FactoryBot.define do
  factory :user do
    uid { "MyString" }
    username { "MyString" }
    email { "MyString" }
    lang { "MyString" }
    is_deleted { false }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
