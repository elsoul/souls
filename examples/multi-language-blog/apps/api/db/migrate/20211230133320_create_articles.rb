class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.belongs_to :user
      t.string :category, null: false, default: ""
      t.string :tags, array: true, null: false, default: []
      t.string :slug, null: false, default: ""
      t.boolean :published, null: false, default: false

      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end
    add_index :articles, :category
    add_index :articles, :tags
  end
end
