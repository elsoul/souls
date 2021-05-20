class UserPolicy < ApplicationPolicy
  def show?
    admin_permissions?
  end

  def index?
    admin_permissions?
  end

  def create?
    admin_permissions?
  end

  def update?
    admin_permissions?
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
