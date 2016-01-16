class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    # Don't need devise auth sessions
    sign_out()

    render json: resource.token, status: :created
  end
end
