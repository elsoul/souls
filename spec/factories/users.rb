FactoryBot.define do
  factory :user do
    uid { "MyString" }
    username { "MyString" }
    screen_name { "MyString" }
    last_name { "MyString" }
    first_name { "MyString" }
    last_name_kanji { "MyString" }
    first_name_kanji { "MyString" }
    last_name_kana { "MyString" }
    first_name_kana { "MyString" }
    email { "MyString" }
    tel { "MyString" }
    icon_url { "MyString" }
    birthday { "MyString" }
    gender { "MyString" }
    lang { "MyString" }
    category { "MyString" }
    roles_mask { rand(1..10) }
    is_deleted { false }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
