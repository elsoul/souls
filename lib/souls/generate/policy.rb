module Souls
  module Generate
    class << self
      ## Generate Policy
      def policy class_name: "souls"
        dir_name = "./app/policies"
        FileUtils.mkdir_p dir_name unless Dir.exist? dir_name
        file_path = "#{dir_name}/#{class_name.singularize}_policy.rb"
        return "Policy already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class #{class_name.camelize}Policy < ApplicationPolicy
              def show?
                true
              end

              def index?
                true
              end

              def create?
                staff_permissions?
              end

              def update?
                staff_permissions?
              end

              def delete?
                admin_permissions?
              end

              private

              def staff_permissions?
                @user.master? or @user.admin? or @user.staff?
              end

              def admin_permissions?
                @user.master? or @user.admin?
              end
            end
          EOS
        end
        file_path
      rescue StandardError => error
        puts "method error"
        puts error.backtrace
      end
    end
  end
end
