# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:failed_attempts) { 0 }
  let(:user) do
    FactoryBot.create(:user, username: 'hernan', password: 'My_secret_password1',
                             failed_attempts: failed_attempts)
  end

  describe 'validate user password' do
    before { user.password = new_password }

    subject { user.valid? }

    context 'for a valid complex password' do
      let(:new_password) { 'MyPaSSowrd123' }

      it 'sets a valid user' do
        expect(subject).to be true
      end
    end

    context 'for a password length lesser than the minimum' do
      let(:new_password) { 'Ma134' }

      it 'sets a invalid user' do
        expect(subject).to be false
      end
    end
  end

  describe 'validate user full_name' do
    before { user.full_name = new_name }

    subject { user.valid? }

    context 'for a present name' do
      let(:new_name) { 'Pepe Cardenas' }

      it 'sets a valid user' do
        expect(subject).to be true
      end
    end

    context 'for a blank name' do
      let(:new_name) { '' }

      it 'sets a invalid user' do
        expect(subject).to be false
      end
    end
  end

  describe 'authenticate an user' do
    subject { user.authenticate(password) }

    context 'with a matching password' do
      let(:password) { 'My_secret_password1' }

      it 'authenticates successfully' do
        expect(subject.username).to eq('hernan')
      end
    end

    context 'without a matching password' do
      let(:password) { 'hack_password' }

      it 'fails authentication' do
        expect(subject).to be false
      end
    end
  end

  describe 'determine if a user is blocked' do
    subject { user.blocked? }

    context 'number of failed attempts not reached yet' do
      let(:failed_attempts) { Rails.application.config.failed_attempts_to_block - 1 }

      it 'should be blocked' do
        expect(subject).to be false
      end
    end

    context 'number of failed attempts reached' do
      let(:failed_attempts) { Rails.application.config.failed_attempts_to_block }

      it 'should be blocked' do
        expect(subject).to be true
      end
    end
  end
end
