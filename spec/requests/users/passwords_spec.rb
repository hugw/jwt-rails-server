require 'rails_helper'

#########
# SCENARIO
##############
# User auth: Password API
###############################
describe "User auth: Password API" do
  before(:each) do
    # Set request headers
    @request_headers = {}

    # Create new user
    @user = create(:user)

    # Set attributes
    @attrs = {
      user: {
        email: @user.email,
        callback_url: 'http://hugw.io',
        password: @user.password,
        password_confirmation: @user.password,
        reset_password_token: 'invalid token representation'
      }
    }
  end


  #########
  # CONTEXT
  ##############
  # HTML action
  ###############################
  context "HTML action" do
    it "should return a bad request error when POST /users/password.html" do
      # POST
      post "/users/password.html", @attrs, @request_headers

      expect(response.status).to eq 400
    end


    it "should return a bad request error when PUT /users/password.html" do
      # PUT
      put "/users/password.html", @attrs, @request_headers

      expect(response.status).to eq 400
    end


    it "should return a bad request error when PATCH /users/password.html" do
      # PATCH
      put "/users/password.html", @attrs, @request_headers

      expect(response.status).to eq 400
    end
  end


  #########
  # CONTEXT
  ##############
  # POST /users/password
  ###############################
  context "POST /users/password" do
    it "should send reset password instructions successfully" do
      # POST
      post "/users/password", @attrs, @request_headers

      expect(response.status).to eq 204
    end


    it "should return 'BLANK' error code when 'callback_url' is empty" do
      @attrs[:user].delete(:callback_url)

      # POST
      post "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "BLANK"
    end


    it "should return 'BLANK' error code when 'email' is empty" do
      @attrs[:user].delete(:callback_url)

      # POST
      post "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "BLANK"
    end


    it "should return 'NOT_FOUND' error code when 'email' is not found" do
      @attrs[:user][:email] = "notfound@hugw.io"

      # POST
      post "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "NOT_FOUND"
    end
  end


  #########
  # CONTEXT
  ##############
  # PUT /users/password
  ###############################
  context "PUT /users/password" do
    it "should reset password successfully" do
      token = @user.send_reset_password_instructions

      @attrs[:user][:reset_password_token] = token

      # PUT
      put "/users/password", @attrs, @request_headers

      expect(response.status).to eq 204
    end


    it "should return 'USER_INACTIVE' error code when user is inactive" do
      token = @user.send_reset_password_instructions

      @attrs[:user][:reset_password_token] = token

      @user.status = 'inactive'
      @user.save

      # PUT
      put "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_INACTIVE"
    end


    it "should return 'INVALID' error code when 'token' is invalid" do
      # PUT
      put "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["reset_password_token"]).to include "INVALID"
    end


    it "should return 'BLANK' error code when 'token' is blank" do
      @attrs[:user].delete(:reset_password_token)

      # PUT
      put "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["reset_password_token"]).to include "BLANK"
    end


    it "should return 'BLANK' error code when 'password' is blank" do
      token = @user.send_reset_password_instructions

      @attrs[:user][:reset_password_token] = token
      @attrs[:user].delete(:password)

      # PUT
      put "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["password"]).to include "BLANK"
    end


    it "should return 'TOO_SHORT' error code when 'password' is too short in length" do
      token = @user.send_reset_password_instructions

      @attrs[:user][:reset_password_token] = token
      @attrs[:user][:password] = '123'
      @attrs[:user][:password_confirmation] = '123'

      # PUT
      put "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["password"]).to include "TOO_SHORT"
    end


    it "should return 'CONFIRMATION' error code when 'password' and 'password confirmation' does not match" do
      token = @user.send_reset_password_instructions

      @attrs[:user][:reset_password_token] = token
      @attrs[:user][:password] = '123123123'

      # PUT
      put "/users/password", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["password_confirmation"]).to include "CONFIRMATION"
    end
  end
end
