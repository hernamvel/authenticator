# frozen_string_literal: true

class User < RedisRecord
  include ActiveModel::SecurePassword

  attr_accessor :username, :full_name, :failed_attempts, :password_digest, :session_token

  has_secure_password

  validates :username, presence: true
  validates :full_name, presence: true

  validate :password_complexity
  validate :record_unique

  def id
    username
  end

  def blocked?
    @failed_attempts >= Rails.application.config.failed_attempts_to_block
  end

  def increment_failed_attempts
    @failed_attempts += 1 unless blocked?
  end

  # For ActiveModel::Serializers::JSON
  def attributes
    {
      'full_name' => nil,
      'username' => nil,
      'failed_attempts' => nil,
      'password_digest' => nil,
      'session_token' => nil
    }
  end

  private

  def record_unique
    # We don't attempt to change the username key, so we're good on update
    return if persisted?

    user = User.find_by(username)
    errors.add(:username, :already_taken) if user.present?
  end

  def password_complexity
    passwd = password
    # has_secure_password will take care of blank passwords safely
    return if passwd.nil?

    errors.add(:password, :minimum_length) if passwd.length < Rails.application.config.min_password_length
    errors.add(:password, :at_least_one_upcase) if passwd.match(/[A-Z]/).blank?
    errors.add(:password, :at_least_one_digit) if passwd.match(/[0-9]/).blank?
  end
end
