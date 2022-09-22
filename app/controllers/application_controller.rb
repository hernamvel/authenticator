# frozen_string_literal: true

class ApplicationController < ActionController::API
  def authenticated?
    @encoded_token = token_from_header
    begin
      @decoded_token = JwtSessionService.decode(@encoded_token)
      render json: { errors: 'invalid user' }, status: :unauthorized if current_user.blank?
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def current_user
    return @current_user if @current_user.present?

    @current_user = User.find_by(username: @decoded_token[:username])
    @current_user.present? && @current_user.session_token == @encoded_token ? @current_user : nil
  end

  private

  def token_from_header
    header = request.headers['Authorization']
    header.present? ? header.split(' ').last : nil
  end
end
