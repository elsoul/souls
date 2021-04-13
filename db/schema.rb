# This is Test Schema
# All the files created by this schema.rb

ActiveRecord::Schema.define(version: 20_210_308_070_947) do
  enable_extension "plpgsql"

  create_table "article_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "tags", default: [], array: true
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["is_deleted"], name: "index_article_categories_on_is_deleted"
    t.index ["name"], name: "index_article_categories_on_name"
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.text "body", default: "", null: false
    t.string "thumnail_url", default: "", null: false
    t.datetime "public_date", default: "2021-05-07 11:45:23", null: false
    t.bigint "article_category_id", null: false
    t.boolean "is_public", default: false, null: false
    t.boolean "just_created", default: true, null: false
    t.string "slag", null: false
    t.text "tags", default: [], array: true
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_category_id"], name: "index_articles_on_article_category_id"
    t.index ["is_deleted"], name: "index_articles_on_is_deleted"
    t.index ["is_public"], name: "index_articles_on_is_public"
    t.index ["slag"], name: "index_articles_on_slag", unique: true
    t.index ["title"], name: "index_articles_on_title", unique: true
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "retailer_uid"
    t.string "uid", null: false
    t.string "username", default: "", null: false
    t.string "screen_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name_kanji", default: "", null: false
    t.string "first_name_kanji", default: "", null: false
    t.string "last_name_kana", default: "", null: false
    t.string "first_name_kana", default: "", null: false
    t.string "email", null: false
    t.string "tel", default: "", null: false
    t.string "icon_url", default: "", null: false
    t.string "birthday", default: "", null: false
    t.string "gender", default: "", null: false
    t.string "lang", default: "ja", null: false
    t.string "category", default: "user", null: false
    t.integer "user_role", default: 0, null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_deleted"], name: "index_users_on_is_deleted"
    t.index ["screen_name"], name: "index_users_on_screen_name"
    t.index ["uid"], name: "index_users_on_uid"
    t.index ["username"], name: "index_users_on_username"
  end
end
