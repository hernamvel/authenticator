# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      before_action :authenticated?, only: [:sign_out]

      def sign_in
        permitted = params.permit(:username, :password)
        auth_service = AuthenticationService.new(permitted[:username])
        result =  auth_service.authenticate(permitted[:password])
        if result == :authenticated
          render json: { token: auth_service.token }, status: :ok
        else
          render json: { error: result.to_s }, status: :unauthorized
        end
      end

      def sign_out
        current_user.session_token = nil
        current_user.save!
      end
    end
  end
end
