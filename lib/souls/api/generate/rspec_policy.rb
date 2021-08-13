module Souls
  module Api::Generate
    ## Generate Rspec Policy
    def self.rspec_policy(class_name: "souls")
      dir_name = "./spec/policies"
      FileUtils.mkdir_p(dir_name) unless Dir.exist?(dir_name)
      file_path = "./spec/policies/#{class_name}_policy_spec.rb"
      return "RspecPolicy already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |new_line|
        new_line.write(<<~TEXT)
          describe #{class_name.camelize}Policy do
            subject { described_class.new(user, #{class_name.underscore}) }

            let(:#{class_name.underscore}) { FactoryBot.create(:#{class_name.underscore}) }

            context "being a visitor" do
              let(:user) { FactoryBot.create(:user, roles: :normal) }

              it { is_expected.to permit_action(:index) }
              it { is_expected.to permit_action(:show) }
              it { is_expected.to forbid_actions([:create, :update, :delete]) }
            end

            context "being a user" do
              let(:user) { FactoryBot.create(:user, roles: :user) }

              it { is_expected.to permit_actions([:create, :update]) }
            end

            context "being an admin" do
              let(:user) { FactoryBot.create(:user, roles: :admin) }

              it { is_expected.to permit_actions([:create, :update, :delete]) }
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
