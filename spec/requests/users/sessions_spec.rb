require 'rails_helper'


#########
# SCENARIO
##############
# User auth: Session API
###############################
describe "User auth: Session API" do
  before(:each) do
    # Set request headers
    @request_headers = {}

    # Create new user
    @user = create(:user)

    # Set attributes
    @attrs = {
      user: {
        email: @user.email,
        password: @user.password
      }
    }
  end


  #########
  # CONTEXT
  ##############
  # HTML actions
  ###############################
  context "HTML actions" do
    it "should return a bad request error when POST /users/sign_in.html" do
      # POST
      post "/users/sign_in.html", @attrs, @request_headers

      expect(response.status).to eq 400
    end
  end


  #########
  # CONTEXT
  ##############
  # POST /users/sign_in
  ###############################
  context "POST /users/sign_in" do
    it "should create a session successfully" do
      # POST
      post "/users/sign_in", @attrs, @request_headers

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


    it "should return 'INVALID_USER_PASSWORD' error code" do
      @attrs[:user].delete(:password)

      # POST
      post "/users/sign_in", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "INVALID_USER_PASSWORD"
    end


    it "should return 'USER_INACTIVE' error code when user is inactive" do
      @user.status = 'inactive'
      @user.save!

      # POST
      post "/users/sign_in", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "USER_INACTIVE"
    end


    it "should return 'UNAUTHENTICATED' error code" do
      @attrs[:user].delete(:password)
      @attrs[:user].delete(:email)

      # POST
      post "/users/sign_in", @attrs, @request_headers

      # Retrieve response body
      body = JSON.parse(response.body)

      expect(response.status).to eq 401
      expect(body["error"]).to eq "UNAUTHENTICATED"
    end
  end
end
