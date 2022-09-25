# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      # Taken from: https://gist.github.com/riskimidiw/1452a0b3d423645c08bc2255282f8892#file-users_controller-rb
      # although this should be scaffolded as well.

      before_action :authenticated?
      before_action :find_user, except: %i[create]

      # GET /users/{username}
      def show
        render json: @user, status: :ok
      end

      # POST /users
      def create
        @user = User.new(user_params_create)
        if @user.save
          render json: @user, status: :created
        else
          render json: { errors: @user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      # PUT /users/{username}
      def update
        if @user.update(user_params_update)
          render json: @user, status: :ok
        else
          render json: { errors: @user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      # DELETE /users/{username}
      def destroy
        @user.destroy
      end

      private

      def find_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'User not found' }, status: :not_found
      end

      def user_params_create
        params.permit(:full_name, :username, :password)
      end

      def user_params_update
        params.permit(:full_name, :password)
      end

    end
  end
end
