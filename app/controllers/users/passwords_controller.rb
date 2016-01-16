class Users::PasswordsController < Devise::PasswordsController
  def create
    rparams = resource_params
    rparams.delete('email') unless rparams['callback_url'].present?
    resource_class.callback_url = rparams.delete('callback_url')

    self.resource = resource_class.send_reset_password_instructions(rparams)

    if successfully_sent?(resource)
      render json: nil, status: :no_content
    else
      # Show errors
      respond_with resource
    end
  end
end
