class AccountController < ApplicationController
  # GET /profile
  def show
    render json: @current_user
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
