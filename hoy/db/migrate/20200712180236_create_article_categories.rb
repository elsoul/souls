class CreateArticleCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :article_categories do |t|
      t.string :name, null: false
      t.text :tags, array: true, default: []
      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end
    add_index :article_categories, :name
    add_index :article_categories, :is_deleted
  end
end
