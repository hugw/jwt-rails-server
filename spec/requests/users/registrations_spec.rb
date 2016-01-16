require 'rails_helper'


#########
# SCENARIO
##############
# User auth: Registration API
###############################
describe "User auth: Registration API" do
  before(:each) do
    # Set request headers
    @request_headers = {}

    # Create new user
    @user = build(:user)

    # Set attributes
    @attrs = {
      user: {
        email: @user.email,
        password: @user.password,
        password_confirmation: @user.password,
        name: @user.name
      }
    }
  end


  #########
  # CONTEXT
  ##############
  # HTML actions
  ###############################
  context "HTML actions" do
    it "should return a bad request error when POST /users.html" do
      # POST
      post "/users.html", @attrs, @request_headers

      expect(response.status).to eq 400
    end
  end


  #########
  # CONTEXT
  ##############
  # POST /users
  ###############################
  context "POST /users" do
    it "should create a new registration successfully" do
      # POST
      post "/users", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 201
      expect(body).to have_key("token")

      # Retrieve token
      token = body["token"]

      # Decode token
      decoded_token = AuthToken.decode(token)

      expect(decoded_token).to be_a(Hash)
    end


    it "should return 'TAKEN' error code when 'email' is already in use" do
      @user.save

      # POST
      post "/users", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "TAKEN"
    end


    it "should return 'BLANK' error codes when 'email', 'name' and 'password' are blank" do
      @attrs = {}

      # POST
      post "/users", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["email"]).to include "BLANK"
      expect(body["errors"]["name"]).to include "BLANK"
      expect(body["errors"]["password"]).to include "BLANK"
    end


    it "should return 'TOO_SHORT' error codes when 'name' and 'password' are too short in length" do

      @attrs[:user][:name] = 'Shrt'
      @attrs[:user][:password] = '123'
      @attrs[:user][:password_confirmation] = '123'

      # POST
      post "/users", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["name"]).to include "TOO_SHORT"
      expect(body["errors"]["password"]).to include "TOO_SHORT"
    end


    it "should return 'CONFIRMATION' error code when 'password' and 'password confirmation' does not match" do
      @attrs[:user][:password] = '123123123'

      # POST
      post "/users", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(body["errors"]["password_confirmation"]).to include "CONFIRMATION"
    end
  end
end
