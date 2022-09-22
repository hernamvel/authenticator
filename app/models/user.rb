# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :password, length: { minimum: Rails.application.config.min_password_length },
                       if: -> { new_record? || !password.nil? }
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def blocked?
    failed_attempts >= Rails.application.config.failed_attempts_to_block
  end

  def increment_failed_attempts
    self.failed_attempts += 1 unless blocked?
  end
end
