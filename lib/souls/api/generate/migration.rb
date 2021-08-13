module Souls
  module Api
    module Migration
      def self.create_migration(class_name: "user")
        pluralized_class_name = class_name.underscore.pluralize
        system("rake db:create_migration NAME=create_#{pluralized_class_name}")
      end
    end
  end
end
