module Souls
  module Api::Generate
    ## Generate Policy
    def self.policy(class_name: "user")
      dir_name = "./app/policies"
      FileUtils.mkdir_p(dir_name) unless Dir.exist?(dir_name)
      file_path = "#{dir_name}/#{class_name.singularize}_policy.rb"
      return "Policy already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          class #{class_name.camelize}Policy < ApplicationPolicy
            def show?
              true
            end

            def index?
              true
            end

            def create?
              user_permissions?
            end

            def update?
              user_permissions?
            end

            def delete?
              admin_permissions?
            end

            private

            def user_permissions?
              @user.master? or @user.admin? or @user.user?
            end

            def admin_permissions?
              @user.master? or @user.admin?
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue StandardError => e
      raise(StandardError, e)
    end
  end
end
