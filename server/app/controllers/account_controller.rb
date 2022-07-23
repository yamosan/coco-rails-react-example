# email を含めようとするとレスポンスが遅くなる。クライアントは ログイン時に Firebase から直接 email を取得できる為、必須ではない。
class AccountController < ApplicationController
  # GET /profile
  def show
    @email = FirebaseAuth.get_user(uid: @current_user.firebase_uid).email
    render json: {
      **@current_user.attributes,
      email: @email
    }
  end

  # PATCH/PUT /profile
  def update
    if @current_user.update(user_params)
      render json: @current_user
    else
      render json: @current_user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    # TODO: email と password も変更可能にする
    params.permit(:name, :age)
  end
end
