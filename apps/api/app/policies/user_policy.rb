class UserPolicy < ApplicationPolicy
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
    @user.user? or @user.admin? or @user.master?
  end

  def admin_permissions?
    @user.master? or @user.admin?
  end

  def update_user_role?
    @user.master?
  end
end
