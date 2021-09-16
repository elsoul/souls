module Souls
  class CLI < Thor
    desc "db:migrate", "Migrate Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def migrate
      case options[:env]
      when "production"
        system("rake db:migrate RACK_ENV=production")
      when "development"
        system("rake db:migrate")
      when "test"
        system("rake db:migrate RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:create", "Create Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def db_create
      case options[:env]
      when "production"
        system("rake db:create RACK_ENV=production")
      when "development"
        system("rake db:create")
      when "test"
        system("rake db:create RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:seed", "Insert Seed Data"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def seed
      case options[:env]
      when "production"
        system("rake db:seed RACK_ENV=production")
      when "development"
        system("rake db:seed")
      when "test"
        system("rake db:seed RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:reset", "Reset Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def migrate_reset
      case options[:env]
      when "production"
        system("rake db:migrate:reset RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1")
      when "development"
        system("rake db:migrate:reset")
      when "test"
        system("rake db:migrate:reset RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:create_migration [CLASS_NAME]", "Create ActiveRecord Migration File"
    def create_migration(class_name)
      pluralized_class_name = class_name.underscore.pluralize
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
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:add_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def add_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=add_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:rename_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def rename_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=rename_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:change_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def change_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=change_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:remove_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def remove_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=remove_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "db:drop_table [CLASS_NAME]", "Create ActiveRecord Migration File"
    def drop_table(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=drop_table_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
