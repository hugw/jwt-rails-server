object false

extends "api/v1/_token"

child @user => :user do
  extends "api/v1/users/_object"
end
