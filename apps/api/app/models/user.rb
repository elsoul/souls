class User < ActiveRecord::Base
  include RoleModel
  has_many :article

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  private_constant :VALID_EMAIL_REGEX
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  roles :normal, :user, :admin, :master

  before_create :assign_initial_roles

  # Scope
  default_scope -> { order(created_at: :desc) }

  def assign_initial_roles
    roles << [:normal]
  end
end
