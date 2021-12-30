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

ActiveRecord::Schema.define(version: 2021_12_30_141651) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "article_translations", force: :cascade do |t|
    t.bigint "article_id"
    t.string "title", default: "", null: false
    t.string "body", default: "", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id"], name: "index_article_translations_on_article_id"
    t.index ["title"], name: "index_article_translations_on_title"
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "category", default: "", null: false
    t.string "tags", default: [], null: false, array: true
    t.string "slug", default: "", null: false
    t.boolean "published", default: false, null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_articles_on_category"
    t.index ["tags"], name: "index_articles_on_tags"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "username", default: "", null: false
    t.string "email", null: false
    t.string "lang", default: "ja", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_deleted"], name: "index_users_on_is_deleted"
    t.index ["uid"], name: "index_users_on_uid"
    t.index ["username"], name: "index_users_on_username"
  end

end
