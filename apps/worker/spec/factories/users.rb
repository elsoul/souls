require "gimei"
FactoryBot.define do
  factory :user do
    uid { Faker::Internet.password }
    username { Gimei.kanji }
    screen_name { Faker::Internet.unique.username }
    last_name { Gimei.last.hiragana }
    first_name { Gimei.first.hiragana }
    last_name_kanji { Gimei.last.kanji }
    first_name_kanji { Gimei.first.kanji }
    last_name_kana { Gimei.last.katakana }
    first_name_kana { Gimei.last.katakana }
    email { Faker::Internet.unique.email }
    tel { Faker::PhoneNumber.subscriber_number(length: 10) }
    icon_url { "https://picsum.photos/200" }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    gender { Gimei.male }
    lang { "ja" }
    category { "user" }
    roles_mask { :normal }
    is_deleted { false }
  end
end
