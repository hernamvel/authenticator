# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationService do
  let(:username) { 'hernan' }
  let(:failed_attempts) { 0 }

  before do
    FactoryBot.create(:user, username: 'hernan', password: 'My_secret_password1',
                             full_name: 'Hernan Velasquez', failed_attempts: failed_attempts)
  end
  subject { AuthenticationService.new(username) }

  describe 'authenticating an un-existing user' do
    let(:username) { 'pepe' }
    let(:password) { 'My_secret_password1' }

    it 'does not validate successfully in any case' do
      expect(subject.authenticate(password)).to eq(:no_user)
      expect(subject.user).to be nil
    end
  end

  describe 'authenticating an existing user with matching password' do
    let(:password) { 'My_secret_password1' }

    context 'user is unblocked' do
      it 'validates successfully' do
        expect(subject.authenticate(password)).to eq(:authenticated)
        expect(subject.user.blocked?).to be false
        expect(subject.user.failed_attempts).to eq(0)
      end
    end

    context 'user is blocked' do
      let(:failed_attempts) { Rails.application.config.failed_attempts_to_block }

      it 'validates unsuccessfully' do
        expect(subject.authenticate(password)).to eq(:user_blocked)
        expect(subject.user.blocked?).to be true
      end
    end
  end

  describe 'authenticating an existing user with no matching password' do
    let(:password) { 'other_passwoord' }

    context 'user is unblocked' do
      it 'validates unsuccessfully' do
        expect(subject.authenticate(password)).to eq(:authentication_failed)
        expect(subject.user.blocked?).to be false
      end
    end

    context 'user is about to be blocked' do
      let(:failed_attempts) { Rails.application.config.failed_attempts_to_block - 1 }

      it 'validates unsuccessfully' do
        expect(subject.authenticate(password)).to eq(:authentication_failed)
        expect(subject.user.blocked?).to be true
      end
    end

    context 'user is blocked' do
      let(:failed_attempts) { Rails.application.config.failed_attempts_to_block }

      it 'validates unsuccessfully' do
        expect(subject.authenticate(password)).to eq(:user_blocked)
        expect(subject.user.blocked?).to be true
      end
    end
  end
end
