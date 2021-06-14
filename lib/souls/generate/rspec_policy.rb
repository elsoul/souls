module Souls
  module Generate
    class << self
      ## Generate Rspec Policy
      def rspec_policy class_name: "souls"
        dir_name = "./spec/policies"
        FileUtils.mkdir_p dir_name unless Dir.exist? dir_name
        file_path = "./spec/policies/#{class_name}_policy_spec.rb"
        return "RspecPolicy already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |new_line|
          new_line.write <<~EOS
            describe #{class_name.camelize}Policy do
              subject { described_class.new(user, #{class_name.underscore}) }

              let(:#{class_name.underscore}) { FactoryBot.create(:#{class_name.underscore}) }

              context "being a visitor" do
                let(:user) { FactoryBot.create(:user) }

                it { is_expected.to permit_action(:index) }
                it { is_expected.to permit_action(:show) }
                it { is_expected.to forbid_actions([:create, :update, :delete]) }
              end

              context "being a retailer" do
                let(:user) { FactoryBot.create(:user, user_role: 1) }

                it { is_expected.to permit_action(:index) }
                it { is_expected.to permit_action(:show) }
                it { is_expected.to forbid_actions([:create, :update, :delete]) }
              end

              context "being a staff" do
                let(:user) { FactoryBot.create(:user, user_role: 3) }

                it { is_expected.to permit_actions([:create, :update]) }
              end

              context "being an administrator" do
                let(:user) { FactoryBot.create(:user, user_role: 4) }

                it { is_expected.to permit_actions([:create, :update, :delete]) }
              end
            end
          EOS
        end
        file_path
      end
    end
  end
end
