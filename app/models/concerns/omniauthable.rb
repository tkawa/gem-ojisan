module Omniauthable
  extend ActiveSupport::Concern

  module ClassMethods
    def from_omniauth(auth, current_user = nil)
      auth_params = build_auth_params(auth)
      authentication = OauthAuthentication.find_or_initialize_by(provider: auth['provider'], uid: auth['uid'])
      user = current_user || authentication.user || User.new
      user.email ||= auth_params[:email]
      user.name ||= auth_params[:name]
      user.image ||= auth_params[:image]
      user.nickname ||= auth_params[:nickname]
      if user.new_record?
        user.password = Devise.friendly_token[0,20]
        user.skip_confirmation!
      end
      user.save

      authentication.user = user
      authentication.update(auth_params)
      user
    end

    def build_auth_params(auth)
      {
        provider: auth['provider'],
        uid: auth['uid'],
        name: auth['info']['name'],
        nickname: auth['info']['nickname'],
        email: auth['info']['email'],
        image: auth['info']['image'],
        access_token: auth['credentials']['token'],
        secret_token: auth['credentials']['token'],
        auth_hash: auth
      }
    end
  end
end
