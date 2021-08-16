module Souls
  module Api
    module Generate
      class << self
        def create_migration(class_name: "user")
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=create_#{pluralized_class_name}")
        end

        def add_column(class_name: "user")
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=add_#{pluralized_class_name}")
        end

        def rename_column(class_name: "user")
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=rename_#{pluralized_class_name}")
        end

        def change_column(class_name: "user")
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=change_#{pluralized_class_name}")
        end

        def remove_column(class_name: "user")
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=remove_#{pluralized_class_name}")
        end

        def drop_table(class_name: "user")
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=drop_#{pluralized_class_name}")
        end
      end
    end
  end
end
