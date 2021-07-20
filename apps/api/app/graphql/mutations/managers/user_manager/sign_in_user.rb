module Mutations
  module Managers::UserManager
    class SignInUser < BaseMutation
      field :status, String, null: false
      field :token, String, null: true
      field :user_role, String, null: true
      field :username, String, null: true
      argument :token, String, required: false

      def resolve(token:)
        fb_auth(token: token)
        begin
          user = ::User.find_by_uid(@payload["sub"])
          user.update(icon_url: @payload["picture"], username: @payload["name"])
          token_base = JsonWebToken.encode(user_id: user.id)
          {
            status: "ログイン成功!",
            username: user.username,
            token: token_base
          }
        rescue StandardError
          user =
            ::User.new(
              uid: @payload["sub"],
              email: @payload["email"],
              icon_url: @payload["picture"],
              username: @payload["name"],
              user_role: 4
            )
          if user.save
            token = JsonWebToken.encode(user_id: user.id)
            {
              status: "ユーザー新規登録完了!",
              username: user.username,
              token: token,
              user_role: user.user_role
            }
          else
            { status: user.errors.full_messages }
          end
        end
      end
    end
  end
end
