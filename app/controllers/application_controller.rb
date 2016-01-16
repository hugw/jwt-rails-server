class ApplicationController < ActionController::Base
  respond_to :json, except: [:root]
  before_action :json_request?, except: [:root]
  protect_from_forgery with: :null_session

  def root
    # Setup an entry point to nowhere
    render :text => nil, :layout => true
  end

  protected

  def json_request?
     head :bad_request unless request.format == 'application/json'
  end
end
