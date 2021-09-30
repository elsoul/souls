module Souls
  class DB < Thor
    desc "create_migration_rbs [CLASS_NAME]", "Generate ActiveRecord Migration's RBS Template"
    def create_migration_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/db/migrate"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        pluralized_class_name = class_name.underscore.pluralize
        file_path = "#{file_dir}/create_#{pluralized_class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class Create#{pluralized_class_name.camelize}
              def change: () -> untyped
              def create_table: (:#{pluralized_class_name}) { (untyped) -> untyped } -> untyped
              def add_index: (:#{pluralized_class_name}, *untyped) -> untyped
            end
          TEXT
        end
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
