class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def root
  # Setup an entry point to nowhere
  render :text => nil, :layout => true
  end
end
