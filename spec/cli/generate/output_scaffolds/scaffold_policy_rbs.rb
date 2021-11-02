module OutputScaffold
  def self.scaffold_policy_rbs
    <<~POLICYRBS
class UserPolicy
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
    POLICYRBS
  end
end
