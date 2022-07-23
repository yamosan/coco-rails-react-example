class AuthController < ApplicationController
  skip_before_action :authenticate_user!

  def signup
    ActiveRecord::Base.transaction do
      # User.create が失敗したときにトランザクションが機能しない
      firebase_user = FirebaseAuth.create_user(email: params[:email], password: params[:password])
      @user = User.create!(
        **user_params,
        firebase_uid: firebase_user.local_id
      )
    end

    render json: @user, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.message }, status: :unprocessable_entity
  rescue Google::Apis::Error, StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def user_params
    params.permit(:name, :age)
  end
end
