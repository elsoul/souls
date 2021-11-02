module OutputScaffold
  def self.scaffold_rspec_policy
    <<~RSPECPOLICY
describe UserPolicy do
  subject { described_class.new(user, user) }

  let(:user) { FactoryBot.create(:user) }

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
RSPECPOLICY
  end
end
