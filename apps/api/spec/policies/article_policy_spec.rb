describe ArticlePolicy do
  subject { described_class.new(user, article) }

  let(:article) { FactoryBot.create(:article) }

  context "being a visitor" do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.to(permit_action(:show)) }
    it { is_expected.to(forbid_actions(%i[create update delete])) }
  end

  context "being a staff" do
    let(:user) { FactoryBot.create(:user, roles_mask: 3) }

    it { is_expected.to(permit_actions(%i[create update])) }
  end

  context "being an administrator" do
    let(:user) { FactoryBot.create(:user, roles_mask: 4) }

    it { is_expected.to(permit_actions(%i[create update delete])) }
  end
end
