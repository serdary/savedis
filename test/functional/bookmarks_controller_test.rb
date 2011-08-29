require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
  setup do
    @bookmark = bookmarks(:one)
    users(:user_admin).bookmarks << @bookmark
    
    @update = {
      :title => bookmarks(:savedis).title,
      :url => 'http://savedis.com/updated',
      :description => 'Updated Bookmark Desc 1',
      :save_count => 1
    }
    
    @unique_bookmark = {
      :url => 'http://savedis.com/unique' + rand.to_s,
      :bookmark_users_attributes => [{
        :title => bookmarks(:savedis).title,
        :description => 'Updated Bookmark Desc 1',
        :is_private => false
        }]
    }
    
    @tags = 'tag 1,tag 2,tag 3,tag 4,tag 5,tag 6,'
  end

  test "should get popular" do
    get :popular
    assert_response :success
    assert_not_nil assigns(:bookmarks)
  end

  test "should get new" do
    get :new, username: users(:user_admin).username
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bookmark.to_param
    assert_response :success
  end

  test "should create bookmark" do
    bookmark_count = users(:user_admin).bookmark_count
      
    assert_difference('Bookmark.count') do
    post :create, bookmark: @unique_bookmark, tag_value: @tags
    end
  
    users(:user_admin).reload
    assert_equal bookmark_count + 1, users(:user_admin).bookmark_count
    assert_redirected_to popular_path
  end

  test "should show bookmark" do
    get :show, id: @bookmark.to_param
    assert_response :success
  end

  test "should update bookmark" do
    put :update, id: @bookmark.to_param, bookmark: @bookmark.attributes, tag_value: @tags
    assert_redirected_to bookmark_path(assigns(:bookmark))
  end

  test "should delete bookmark from user" do    
    bookmark_count = users(:user_admin).bookmark_count
    
    bookmark_user = users(:user_admin).bookmark_users.find_by_bookmark_id(@bookmark.id)
    assert_equal bookmark_user.is_deleted, false
    
    delete :destroy, id: @bookmark.to_param
    
    bookmark_user = users(:user_admin).bookmark_users.find_by_bookmark_id(@bookmark.id)
    
    bookmark_user.reload
    assert_equal bookmark_user.is_deleted, true

    users(:user_admin).reload
    assert_equal bookmark_count, users(:user_admin).bookmark_count + 1

    assert_redirected_to user_bookmarks_path(:username => users(:user_admin).username)
  end
end
