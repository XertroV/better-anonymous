# frozen_string_literal: true

# require_relative '../../../../../spec/fabricators/user_fabricator.rb'
# require 'spec/fabricators/user_fabricator.rb'

Fabricator(:better_anon, class_name: :user) do
    name 'Anonymous'
    username { sequence(:username) { |i| "anonymous#{i}"} }
    email { sequence(:email) { |i| "anonymous#{i}@anonymous.com" } }
    password 'myawesomepassword'
    trust_level TrustLevel[1]
    manual_locked_trust_level TrustLevel[1]
    ip_address { sequence(:ip_address) { |i| "99.232.23.#{i % 254}" } }
    active true

    # after_create do
    #   create_anonymous_user_master(master_user_id: -1, active: true)
    # end
end