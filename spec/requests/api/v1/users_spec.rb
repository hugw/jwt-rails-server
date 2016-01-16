require 'rails_helper'

#########
# SCENARIO
##############
# Users API
###############################
describe "Users API" do

  before(:each) do
    # Set API base url
    @url = '/api/v1'

    # Set request headers
    @request_headers = {}

    # Create new user
    @user = create(:user)

    # Set token
    @request_headers["Authorization"] = @user.token(true)

    # Set attributes
    @attrs = {
      user: {
        email: Faker::Internet.email,
        password: 'admin1234',
        password_confirmation: 'admin1234',
        name: Faker::Name.name
      }
    }

    @sign_in = {
      user: {
        email:    @attrs[:user][:email],
        password: @attrs[:user][:password],
      }
    }
  end

  #########
  # CONTEXT
  ##############
  # All requests
  ###############################
  context "All requests" do
    it "should return 'MISSING_TOKEN' error code when not passing any auth token" do
      # GET user info
      get "#{@url}/user", {}

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "MISSING_TOKEN"

      ################

      # PUT user info
      put "#{@url}/user", {}, {}

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "MISSING_TOKEN"
    end


    it "should return 'INVALID_TOKEN' error code when passing an invalid token" do
      # Tempered token
      @request_headers["Authorization"] = 'invalid token here'

      # GET user info
      get "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "INVALID_TOKEN"

      ################

      # PUT user info
      put "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "INVALID_TOKEN"
    end


    it "should return 'USER_INACTIVE' error code when user is inactive" do
      # Inactivate user
      @user.status!(:inactive)
      @user.save

      # GET user info
      get "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_INACTIVE"

      ################

      # PUT user info
      put "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_INACTIVE"
    end


    it "should return 'USER_NOT_FOUND' error code when user is not found" do
      # Delete user
      @user.destroy

      # GET user info
      get "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_NOT_FOUND"

      ################

      # PUT user info
      put "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_NOT_FOUND"
    end
  end

  #########
  # SCENARIO
  ##############
  # GET /user
  ###############################
  context "GET /user" do
    it "should return the current user data" do
      # GET
      get "#{@url}/user", {}, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)
      user = body["user"]

      expect(response.status).to eq 202
      expect(user["name"]).to eq @user.name
      expect(user["email"]).to eq @user.email
    end
  end


  #########
  # SCENARIO
  ##############
  # PUT /user
  ###############################
  context "PUT /user" do
    it "should return 'USER_NOT_FOUND' error code when user is not found" do
      # Delete user
      @user.destroy

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_NOT_FOUND"
    end


    it "should edit the current user profile successfully" do
      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)
      user = body["user"]

      expect(response.status).to eq 202
      expect(user["name"]).to eq @attrs[:user][:name]
      expect(user["email"]).to eq @attrs[:user][:email]

      # try to login with new credentials
      @user.reload

      post "/users/sign_in", @sign_in, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 201
      expect(body).to have_key("token")

      # Retrieve token
      token = body["token"]

      # Decode token
      decoded_token = AuthToken.decode(token)

      expect(decoded_token).to be_a(Hash)
      expect(decoded_token["user"]["id"]).to eq @user.id
    end


    it "should edit the current user profile successfully and return a renewed token" do
      #Set old token
      @request_headers["Authorization"] = @user.token(true, 10.minutes.ago.to_i)

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)
      user = body["user"]
      renewed_token = body["token"]

      expect(response.status).to eq 202
      expect(user["name"]).to eq @attrs[:user][:name]
      expect(user["email"]).to eq @attrs[:user][:email]
      expect(renewed_token).to be_truthy
    end


    it "should edit the current user profile successfully even if password field is empty (do not throw blank error)" do
      @attrs[:user][:password] = ''
      @attrs[:user][:password_confirmation] = ''

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)
      user = body["user"]

      expect(response.status).to eq 202
      expect(user["name"]).to eq @attrs[:user][:name]
      expect(user["email"]).to eq @attrs[:user][:email]

      # try to login with new credentials
      @user.reload

      # Get old password since it wasn't updated
      @sign_in[:user][:password] = @user.password

      post "/users/sign_in", @sign_in, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 201
      expect(body).to have_key("token")

      # Retrieve token
      token = body["token"]

      # Decode token
      decoded_token = AuthToken.decode(token)

      expect(decoded_token).to be_a(Hash)
      expect(decoded_token["user"]["id"]).to eq @user.id
    end


    it "should return 'BLANK' error codes when 'email', and 'name' are blank" do
      # Delete name
      @attrs[:user][:name] = ''
      # Delete email
      @attrs[:user][:email] = ''

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["name"]).to include "BLANK"
      expect(body["errors"]["email"]).to include "BLANK"
    end


    it "should return 'TAKEN' error code when 'email' in already in use" do
      # Set new user
      user = create(:user)
      # Get his email
      @attrs[:user][:email] = user.email

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "TAKEN"
    end


    it "should return 'INVALID' error code when 'email' in invalid" do
      # Set email invalid
      @attrs[:user][:email] = 'invalid email'

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "INVALID"
    end


    it "should return 'TOO_SHORT' error codes when 'name' and 'password' are too short in length" do
      # Short name
      @attrs[:user][:name] = 'aa'
      # Short password
      @attrs[:user][:password] = '123'

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["name"]).to include "TOO_SHORT"
      expect(body["errors"]["password"]).to include "TOO_SHORT"
    end


    it "should return 'CONFIRMATION' error code when 'password' and 'password confirmation' does not match" do
      @attrs[:user][:password] = '123123123'

      # PUT
      put "#{@url}/user", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["password_confirmation"]).to include "CONFIRMATION"
    end
  end
end
