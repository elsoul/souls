module Scaffold
  def self.scaffold_create_migration
    <<~CREATEMIGRATION
      class CreateUsers < ActiveRecord::Migration[6.1]
        def change
          create_table :users do |t|

            t.boolean :is_deleted, null: false, default: false
            t.timestamps
          end
        end
      end
    CREATEMIGRATION
  end
end
