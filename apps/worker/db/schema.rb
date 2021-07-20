# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_14_215521) do

  # These are extensions that must be enabled in order to support this database
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
    t.datetime "public_date", default: "2021-08-18 18:14:54", null: false
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
    t.integer "roles_mask", default: 1, null: false
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
