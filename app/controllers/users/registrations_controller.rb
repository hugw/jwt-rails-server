class Users::RegistrationsController < Devise::RegistrationsController
  before_action :permitted_params

  def create
    build_resource(sign_up_params)

    resource.status!(:active)

    resource.save
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        render json: resource.token, status: :created
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      # Show errors
      respond_with resource
    end
  end

  private

  def permitted_params
    devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
