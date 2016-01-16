class Api::V1::UsersController < Api::V1Controller
  before_action :user_has_creds?, only: [:update, :show]

  def update
    # If password is empty when editing
    # we suppose user don't want to
    # edit it.
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update_attributes(user_params)
      # Retrieve new token
      @token = @user.token

      render "show", status: :accepted
    else
      respond_with @user
    end
  end

  def show
    render "show", status: :accepted
  end

  private

  def user_has_creds?
    @user = user_with_creds
    user_404 unless @user.present?
  end

  def user_404
    render json: { error: 'USER_NOT_FOUND' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
