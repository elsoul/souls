describe ArticlePolicy do
  subject { described_class.new(user, article) }

  let(:article) { FactoryBot.create(:article) }

  context "being a normal" do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.to(permit_actions(%i[index show])) }
    it { is_expected.to(forbid_actions(%i[create update delete])) }
  end

  context "being a user" do
    let(:user) { FactoryBot.create(:user, roles: :user) }

    it { is_expected.to(permit_actions(%i[create update])) }
  end

  context "being an admin" do
    let(:user) { FactoryBot.create(:user, roles: :admin) }

    it { is_expected.to(permit_actions(%i[create update delete])) }
  end
end
