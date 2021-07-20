describe UserPolicy do
  subject { described_class.new(user, user) }

  let!(:user) { FactoryBot.create(:user) }
end
