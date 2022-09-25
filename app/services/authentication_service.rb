# frozen_string_literal: true

class AuthenticationService
  attr_reader :user

  def initialize(username)
    @user = User.find(username)
  rescue ActiveRecord::RecordNotFound
    @user = nil
  end

  def authenticate(password)
    return :no_user unless @user.present?

    return :user_blocked if @user.blocked?

    result = if @user.authenticate(password)
               :authenticated
             else
               :authentication_failed
             end
    @user.save!
    result
  end

  def token
    @user.session_token
  end
end
