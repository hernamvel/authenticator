# frozen_string_literal: true

class AuthenticationService

  attr_reader :user

  def initialize(username)
    begin
      @user = User.find(username)
    rescue ActiveRecord::RecordNotFound
      @user = nil
    end
  end

  def authenticate(password)
    return :no_user unless @user.present?

    return :user_blocked if @user.blocked?

    result = if @user.authenticate(password)
               @user.failed_attempts = 0
               @user.session_token = JwtSessionService.encode(username: @user.username)
               :authenticated
             else
               @user.increment_failed_attempts
               :authentication_failed
             end
    @user.save!
    result
  end

  def token
    @user.session_token
  end
end
