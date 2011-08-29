require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  setup do
    @note = notes(:one)
    
    users(:user_admin).notes << @note
  end

  test "should get new" do
    get :new, username: users(:user_admin).username
    assert_response :success
  end

  test "should create note" do
    note_count = users(:user_admin).note_count
    
    assert_difference('Note.count') do
      post :create, note: @note.attributes
    end

    users(:user_admin).reload
    assert_equal note_count + 1, users(:user_admin).note_count
    
    assert_redirected_to note_path(assigns(:note))
  end

  test "should show note" do
    get :show, id: @note.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @note.to_param
    assert_response :success
  end

  test "should update note" do
    put :update, id: @note.to_param, note: @note.attributes
    assert_redirected_to note_path(assigns(:note))
  end

  test "should delete note from user" do  
    note_count = users(:user_admin).note_count
    
    assert_equal @note.is_deleted, false

    delete :destroy, id: @note.to_param

    @note.reload
    assert_equal @note.is_deleted, true

    users(:user_admin).reload
    assert_equal note_count, users(:user_admin).note_count + 1

    assert_redirected_to user_notes_path(:username => users(:user_admin).username)
  end
end
