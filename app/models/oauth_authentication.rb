class OauthAuthentication < ApplicationRecord
  belongs_to :user

  validates :provider, :uid, presence: true
  serialize :auth_hash, JSON
end
