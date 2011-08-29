require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:user_admin)
    
    @unique_user = {
      :username => 'unq_username',
      :email => "unq_email_#{rand.to_s}@uniq.com",
      :hashed_password => 'hashed',
      :salt => 'salt'
    }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: @unique_user
    end

    assert_redirected_to user_profile_path(:username => @unique_user[:username])
  end

  test "should show user" do
    get :show, username: @user.username
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user.to_param, user: @unique_user
    assert_redirected_to settings_path
  end

  test "should access to settings page" do
    get :settings
    assert_response :success
  end

  test "should not access to settings page" do
    session.delete :user_id
    get :settings
    
    assert_redirected_to login_path
  end
end
