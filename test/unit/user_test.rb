require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "username must not be empty" do
    user = User.new
    
    assert user.invalid?
    assert_equal "can't be blank;is invalid;is too short (minimum is 1 characters)", user.errors[:username].join(';')
  end

  test "username must be unique" do
    user = User.new(
      :username => users(:user1).username,
      :email => "email_#{rand.to_s}@test.com"
    )

    assert user.invalid?
    assert_equal "has already been taken", user.errors[:username].join(';')
  end
  
  test "email must not be empty" do
    user = User.new(
      :username => users(:user1).username + rand.to_s
    )
    
    assert user.invalid?
    assert_equal "can't be blank;is invalid", user.errors[:email].join(';')
  end
  
  test "email must be valid" do
    user = User.new(
      :username => users(:user1).username,
      :email => "email_#{rand.to_s}m"
    )

    assert user.invalid?
    assert_equal "is invalid", user.errors[:email].join(';')
  end

  test "email must be unique" do
    user = User.new(
      :username => users(:user2).username,
      :email => users(:user1).email
    )

    assert user.invalid?
    assert_equal "has already been taken", user.errors[:email].join(';')
  end
  
  test "should update counters" do
    bookmark_count = users(:user1).bookmark_count
    note_count = users(:user1).note_count
    
    users(:user1).update_counters('bookmark')
    users(:user1).update_counters('note')
    
    assert_equal(bookmark_count+1, users(:user1).bookmark_count)
    assert_equal(note_count+1, users(:user1).note_count)
  end
end
