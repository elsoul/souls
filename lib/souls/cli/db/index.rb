require_relative "./create_migration_rbs"
require_relative "./model"
require_relative "./rspec_model"
require_relative "./model_rbs"
module Souls
  class DB < Thor
    desc "migrate", "Migrate Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def migrate
      case options[:env]
      when "production"
        system("rake db:migrate RACK_ENV=production")
      else
        system("rake db:migrate")
        system("rake db:migrate RACK_ENV=test")
      end
      true
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "create", "Create Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def create
      case options[:env]
      when "production"
        system("rake db:create RACK_ENV=production")
      else
        system("rake db:create")
        system("rake db:create RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "seed", "Insert Seed Data"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def seed
      case options[:env]
      when "production"
        system("rake db:seed RACK_ENV=production")
      else
        system("rake db:seed")
        system("rake db:seed RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "migrate_reset", "Reset Database"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def migrate_reset
      case options[:env]
      when "production"
        system("rake db:migrate:reset RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1")
      else
        system("rake db:migrate:reset")
        system("rake db:migrate:reset RACK_ENV=test")
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "create_migration [CLASS_NAME]", "Create ActiveRecord Migration File"
    def create_migration(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      singularized_class_name = class_name.underscore.singularize
      Souls::DB.new.invoke(:model, [singularized_class_name], {})
      Souls::DB.new.invoke(:rspec_model, [singularized_class_name], {})
      Souls::DB.new.invoke(:model_rbs, [singularized_class_name], {})
      puts(Paint["Created file! : ", :green])
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

    desc "add_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def add_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=add_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "rename_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def rename_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=rename_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "change_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def change_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=change_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "remove_column [CLASS_NAME]", "Create ActiveRecord Migration File"
    def remove_column(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=remove_column_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "drop_table [CLASS_NAME]", "Create ActiveRecord Migration File"
    def drop_table(class_name)
      pluralized_class_name = class_name.underscore.pluralize
      system("rake db:create_migration NAME=drop_table_to_#{pluralized_class_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
