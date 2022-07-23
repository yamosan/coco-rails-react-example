class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate_user!

  def current_user
    authenticate_with_http_token do |id_token, _options|
      uid = FirebaseAuth.verify_id_token(id_token)['uid']
      @current_user ||= User.find_by(firebase_uid: uid)
    rescue StandardError => e
      Rails.logger.error(e.message)
      nil
    end
  end

  def authenticate_user!
    user_signed_in? || render_unauthorized
  end

  protected

  def user_signed_in?
    !current_user.nil?
  end

  def render_unauthorized
    obj = { message: 'token invalid' }
    render json: obj, status: :unauthorized
  end
end
