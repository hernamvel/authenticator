# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { 'hernan' }
    full_name { 'Hernan Velasquez' }
    email { 'hernamvel@gmail.com' }
    password { 'my_secure_password' }
    failed_attempts { 0 }
    session_token { 'xxx' }
  end
end
