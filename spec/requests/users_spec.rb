# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:authenticated) { true }
  let(:user) do
    FactoryBot.create(:user, username: 'hernan', password: 'My_secret_password1',
                             failed_attempts: 0)
  end

  before do
    service = AuthenticationService.new(user.username)
    @headers = { 'ACCEPT' => 'application/json' }
    if authenticated
      service.authenticate('My_secret_password1')
      @headers['Authorization'] = service.token
    end
  end

  describe 'GET /api/v1/user/:id' do
    let(:user_id) { user.id }

    before do
      get "/api/v1/users/#{user_id}", headers: @headers
    end

    context 'with a valid authentication token and existing user' do
      it 'return status ok' do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['username']).to eq(user.id)
      end
    end

    context 'with a valid authentication token and a non existing user' do
      let(:user_id) { 0 }

      it 'return status not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an invalid authentication token' do
      let(:authenticated) { false }

      it 'return status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/users' do
    let(:full_name_create) { 'Hernan Mauricio Velasquez' }
    let(:new_user_name) { 'hernamvel' }

    before do
      params = { username: new_user_name, password: 'My_2nd_password',
                 full_name: full_name_create }
      post '/api/v1/users', headers: @headers, params: params
    end

    context 'with a valid authentication token and valid parameters' do
      it 'return status created' do
        expect(response).to have_http_status(:created)
        expect(User.find('hernamvel')).to be_present
      end
    end

    context 'with valid authentication token but an existing username' do
      let(:new_user_name) { 'hernan' }

      it 'return status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with a valid authentication token but empty full_name' do
      let(:full_name_create) { nil }

      it 'return status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with an invalid authentication token' do
      let(:authenticated) { false }

      it 'return status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/users' do
    let(:name_to_update) { 'Juan' }

    before do
      params = { full_name: name_to_update }
      patch "/api/v1/users/#{user.id}", headers: @headers, params: params
    end

    context 'with a valid authentication token and valid params' do
      it 'return status ok' do
        expect(response).to have_http_status(:ok)
        expect(User.find(user.id).full_name).to eq('Juan')
      end
    end

    context 'with a valid authentication token but empty full_name' do
      let(:name_to_update) { nil }

      it 'return status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with an invalid authentication token' do
      let(:authenticated) { false }

      it 'return status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/users' do
    before do
      delete "/api/v1/users/#{user.id}", headers: @headers
    end

    context 'with a valid authentication token' do
      it 'return status ok' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with an invalid authentication token' do
      let(:authenticated) { false }

      it 'return status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
