class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false, unique: true
      t.string :username, null: false, default: ""
      t.string :email, null: false, unique: true
      t.string :lang, null: false, default: "ja"
      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end
    add_index :users, :uid
    add_index :users, :email, unique: true
    add_index :users, :username
    add_index :users, :is_deleted
  end
end