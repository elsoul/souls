class ArticlePolicy < ApplicationPolicy
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
    @user.master? or @user.admin? or @user.user?
  end

  def admin_permissions?
    @user.master? or @user.admin?
  end
end
