require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:authenticated) { true }
  let(:user) do
    FactoryBot.create(:user, username: 'hernan', password: 'my_secret_password',
                             email: 'hernan@mycompany.com', failed_attempts: 0)
  end

  before do
    service = AuthenticationService.new(user.username)
    @headers = { 'ACCEPT' => 'application/json' }
    if authenticated
      service.authenticate('my_secret_password')
      @headers['Authorization'] = service.token
    end
  end

  describe 'GET /api/v1/users' do
    before do
      get '/api/v1/users', headers: @headers
    end

    context 'with a valid authentication token' do
      it 'return status ok' do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
      end
    end

    context 'with an invalid authentication token' do
      let(:authenticated) { false }

      it 'return status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
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
        expect(response.parsed_body['id']).to eq(user.id)
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
    let(:email_to_create) { 'mauricio@mycompany.com' }

    before do
      params = { username: 'mauricio', password: 'my_other_password',
                 email: email_to_create, full_name: 'Hernan Mauricio Velasquez' }
      post '/api/v1/users', headers: @headers, params: params
    end

    context 'with a valid authentication token and valid parameters' do
      it 'return status created' do
        expect(response).to have_http_status(:created)
        expect(User.count).to eq(2)
      end
    end

    context 'with a valid authentication token but empty email' do
      let(:email_to_create) { nil }

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
        expect(User.count).to eq(0)
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
