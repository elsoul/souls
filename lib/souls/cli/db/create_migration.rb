module SOULs
  class DB < Thor
    desc "create_migration [CLASS_NAME]", "Create ActiveRecord Migration File"
    def create_migration(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      singularized_class_name = class_name.underscore.singularize
      SOULs::DB.new.invoke(:model, [singularized_class_name], {})
      SOULs::DB.new.invoke(:rspec_model, [singularized_class_name], {})
      SOULs::Painter.create_file("")
      system("rake db:create_migration NAME=create_#{pluralized_class_name}")
      file_path = Dir["db/migrate/*create_#{pluralized_class_name}.rb"].first
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          class Create#{pluralized_class_name.camelize} < ActiveRecord::Migration[6.1]
            def change
              create_table :#{pluralized_class_name} do |t|

                t.boolean :is_deleted, null: false, default: false
                t.timestamps
              end
            end
          end
        TEXT
      end
    end
  end
end
