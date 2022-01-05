module SOULs
  class Delete < Thor
    desc "migration [migration_NAME]", "Delete Migration files Template"
    def migration(class_name)
      singularized_class_name = class_name.underscore.singularize
      pluralized_class_name = class_name.underscore.pluralize
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_paths = {
          model_file_path: "./apps/api/app/models/#{singularized_class_name}.rb",
          rspec_file_path: "./apps/api/spec/models/#{singularized_class_name}_spec.rb",
          rbs_file_path: "./sig/api/app/models/#{singularized_class_name}.rbs",
          migration_file_path: Dir["db/migrate/*create_#{pluralized_class_name}.rb"].first
        }
        file_paths.each do |_k, v|
          FileUtils.rm_f(v)
          SOULs::Painter.delete_file(v)
        rescue StandardError => e
          puts(e)
        end
        file_paths
      end
    end
  end
end
