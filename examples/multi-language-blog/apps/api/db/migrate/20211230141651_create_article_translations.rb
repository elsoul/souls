class CreateArticleTranslations < ActiveRecord::Migration[6.1]
  def change
    create_table :article_translations do |t|
      t.belongs_to :article
      t.string :title, null: false, default: ""
      t.string :body, null: false, default: ""

      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end
    add_index :article_translations, :title
  end
end
