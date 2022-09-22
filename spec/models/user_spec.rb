# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { 'hernan@mycompany.com' }
  let(:failed_attempts) { 0 }
  let(:user) do
    FactoryBot.create(:user, username: 'hernan', email: email, password: 'my_secret_password',
                      failed_attempts: failed_attempts)
  end

  describe 'validate user password' do
    before { user.password = new_password }

    subject { user.valid? }

    context 'for a password length greater than the minimum' do
      let(:new_password) { '1234567890' }

      it 'sets a valid user' do
        expect(subject).to be true
      end
    end

    context 'for a password length lesser than the minimum' do
      let(:new_password) { '1234' }

      it 'sets a invalid user' do
        expect(subject).to be false
      end
    end
  end

  describe 'validate user email' do
    before { user.email = new_email }

    subject { user.valid? }

    context 'for a email with a valid format' do
      let(:new_email) { 'hernan@supercompany.com' }

      it 'sets a valid user' do
        expect(subject).to be true
      end
    end

    context 'for a email with no format' do
      let(:new_email) { '1234' }

      it 'sets a invalid user' do
        expect(subject).to be false
      end
    end

    context 'for an empty email' do
      let(:new_email) { nil }

      it 'sets a invalid user' do
        expect(subject).to be false
      end
    end
  end

  describe 'authenticate an user' do
    subject { user.authenticate(password) }

    context 'with a matching password' do
      let(:password) { 'my_secret_password' }

      it 'authenticates successfully' do
        expect(subject.email).to eq(email)
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
