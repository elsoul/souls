module Souls
  class Generate < Thor
    desc "policy_rbs [CLASS_NAME]", "Generate Policy RBS"
    def policy_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/policies/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}_policy.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class #{singularized_class_name.camelize}Policy
              @user: untyped

              def show?: -> true
              def index?: -> true
              def create?: -> bool
              def update?: -> bool
              def delete?: -> bool

              private
              def user_permissions?: -> untyped
              def admin_permissions?: -> untyped
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
