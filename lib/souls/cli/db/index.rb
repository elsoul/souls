require_relative "./create_migration"
require_relative "./create_migration_rbs"
require_relative "./model"
require_relative "./rspec_model"
require_relative "./model_rbs"
require_relative "../cli_exception"

module Souls
  class DB < Thor
    desc "migrate", "Migrate Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def migrate
      case options[:env]
      when "production"
        db_system("rake db:migrate RACK_ENV=production")
      else
        db_system("rake db:migrate")
        db_system("rake db:migrate RACK_ENV=test")
      end
      true
    end

    desc "create", "Create Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def create
      case options[:env]
      when "production"
        db_system("rake db:create RACK_ENV=production")
      else
        db_system("rake db:create")
      end
    end

    desc "seed", "Insert Seed Data"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def seed
      case options[:env]
      when "production"
        db_system("rake db:seed RACK_ENV=production")
      else
        db_system("rake db:seed")
        db_system("rake db:seed RACK_ENV=test")
      end
    end

    desc "migrate_reset", "Reset Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def migrate_reset
      case options[:env]
      when "production"
        db_system("rake db:migrate:reset RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1")
      else
        db_system("rake db:migrate:reset")
        db_system("rake db:migrate RACK_ENV=test")
      end
    end

    desc "add_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def add_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=add_column_to_#{pluralized_class_name}")
    end

    desc "rename_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def rename_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=rename_column_to_#{pluralized_class_name}")
    end

    desc "change_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def change_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=change_column_to_#{pluralized_class_name}")
    end

    desc "remove_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def remove_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=remove_column_to_#{pluralized_class_name}")
    end

    desc "drop_table [CLASS_NAME]", "Create ActiveRecord Migration File"
    def drop_table(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=drop_table_to_#{pluralized_class_name}")
    end

    private

    def db_system(cmd)
      system(cmd) or raise(Souls::PSQLException)
    end
  end
end
