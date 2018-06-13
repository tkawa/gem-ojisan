class AuthenticationController < Devise::OmniauthCallbacksController
  # skip_before_action :authenticate_user!

  def omniauth_callback
    @user = User.from_omniauth(request.env["omniauth.auth"], current_user)

    if @user.try(:persisted?)
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: params[:action]) if is_navigational_format?
    else
      set_flash_message(:notice, :failure, kind: params[:action], reason: 'could not create user')
      redirect_to root_path
    end
  end
  alias :google_oauth2 :omniauth_callback

  def failure
    redirect_to request.env['omniauth.origin'] || root_path
  end
end
