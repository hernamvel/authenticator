# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentications', type: :request do

  before do
    FactoryBot.create(:user, username: 'hernan', password: 'my_secret_password',
                             email: 'hernan@mycompany.com', failed_attempts: 0)
  end

  describe 'GET /api/v1/sign_in' do
    before do
      post '/api/v1/sign_in', params: {
        username: username_to_authenticate, password: password_to_authenticate
      }
    end

    context 'for a valid username and matching password' do
      let(:username_to_authenticate) { 'hernan' }
      let(:password_to_authenticate) { 'my_secret_password' }

      it 'return successful authentication' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'for a valid username and no matching password' do
      let(:username_to_authenticate) { 'hernan' }
      let(:password_to_authenticate) { 'my_public_password' }

      it 'return unauthorized authentication' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/sign_out' do

    context 'for a signed user' do
      before do
        post '/api/v1/sign_in', params: {
          username: 'hernan', password: 'my_secret_password'
        }
        token = response.parsed_body["token"]
        headers = { 'ACCEPT' => 'application/json', 'Authorization' => token }
        delete '/api/v1/sign_out', headers: headers
      end

      it 'return successful response' do
        expect(response).to have_http_status(:no_content)
        expect(User.find_by(username: 'hernan').session_token).to be_blank
      end
    end
  end
end
