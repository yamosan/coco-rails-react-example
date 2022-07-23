# email を含めようとするとレスポンスが遅くなる。クライアントは ログイン時に Firebase から直接 email を取得できる為、必須ではない。
class AccountController < ApplicationController
  # GET /account
  def show
    @email = FirebaseAuth.get_user(uid: @current_user.firebase_uid).email
    render json: {
      **@current_user.attributes,
      email: @email
    }
  end

  # PATCH/PUT /account
  def update
    ActiveRecord::Base.transaction do
      @current_user.update!(user_params)

      updated = FirebaseAuth.update_user(
        uid: @current_user.firebase_uid,
        email: params[:email],
        password: params[:password]
      )
      @email = updated.email
    end

    render json: {
      **current_user.attributes,
      email: @email
    }
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.message }, status: :unprocessable_entity
  rescue Google::Apis::Error, StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # DELETE /account
  def destroy
    ActiveRecord::Base.transaction do
      @current_user.destroy!
      FirebaseAuth.delete_user(uid: @current_user.firebase_uid)
    end

    head :no_content
  rescue Google::Apis::Error, StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def user_params
    params.permit(:name, :age)
  end
end
