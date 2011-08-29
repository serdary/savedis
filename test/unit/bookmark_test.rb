require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test "bookmark attrs must not be empty" do
    bookmark = Bookmark.new
    
    assert bookmark.invalid?
    assert bookmark.errors[:url].any?
    
    bookmark.url = rand.to_s + "savedis.com"
    assert bookmark.valid?
  end
  
  test "bookmark url must be valid" do
    bookmark = Bookmark.new(:title => "Test Bookmark 1",
                            :description => "Test Bookmark Desc 1")
                            
    bookmark.url = "savedis.com"
    assert bookmark.valid?
    
    bookmark.url = "http://savedis.com"
    assert bookmark.valid?
    
    bookmark.url = "savedis"
    assert bookmark.invalid?
  end
  
  test "add existing bookmark to user" do    
    bookmark_user = BookmarkUser.new(:user_id => users(:user1).id,
      :title => 'BookmarkUser Title1',
      :description => 'BookmarkUser Desc1',
      :is_private => false,)
    
    save_count = bookmarks(:savedis).save_count
    bookmarks_count = bookmarks.count
    
    assert bookmarks(:savedis).add_bookmark_to_user(bookmark_user)
    
    bookmark_user = users(:user1).bookmark_users(bookmarks(:savedis))
    assert_not_nil bookmark_user
    
    assert_equal(save_count+1, Bookmark.find_by_title('Savedis').save_count)
    assert_equal(bookmarks_count, bookmarks.count)    
  end
  
  test "add a new bookmark to user" do    
    bookmark_user = BookmarkUser.new(:user_id => users(:user2).id,
      :title => 'BookmarkUser Title2',
      :description => 'BookmarkUser Desc2',
      :is_private => true,)
    
    bookmark = Bookmark.new(:title => 'qamini',
      :url => 'http://qamini.com',
      :description => 'qamini desc',
      :created_by => users(:user2).id)

    assert bookmark.add_bookmark_to_user(bookmark_user)
    
    bookmark_user = users(:user2).bookmark_users(bookmark)
    assert_not_nil bookmark_user
    
    assert_equal(1, bookmark.save_count)
  end
end
