class ApplicationController < ActionController::Base
  respond_to :json, except: [:root]
  before_action :json_request?, except: [:root]
  before_action :jwt_authenticated?, unless: :devise_controller?, except: [:root]
  protect_from_forgery with: :null_session

  def root
    # Setup an entry point to nowhere
    render :text => nil, :layout => true
  end

  protected

  def jwt_authenticated?
    begin
      # Any Authorization header?
      raise 'MISSING_TOKEN' if request.headers['Authorization'].nil?

      # Any jwt payload?
      payload = AuthToken.decode(request.headers['Authorization'].split(' ').last)
      raise 'INVALID_TOKEN' unless payload.present?

      # Check if user exists
      user_payload = payload['user']
      @current_user = User.where(id: user_payload['id']).first

      # Found user?
      raise 'USER_NOT_FOUND' if @current_user.nil?

      # it is inactive?
      raise 'USER_INACTIVE' unless @current_user.status?

      # Check if token needs to be updated
      # Soft exp time: 10min
      if user_payload['ping'] < Time.current.to_i
        # Set token to be available on
        # the next call from client
        @token = @current_user.token
      end
    rescue Exception => err
      render json: { error: err.message }, status: :unauthorized
    end
  end

  def json_request?
     head :bad_request unless request.format == 'application/json'
  end

  def user_with_creds
    @current_user unless @current_user.nil?
  end

  def update_token?
    @token unless @token.nil?
  end
end
