require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    @tag = tags(:one)
    
    @unique_tag = {
      :value => "tag_#{rand.to_s}",
      :slug => "blablaaa"
    }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should show tag" do
    get :show, id: @tag.to_param
    assert_response :success
  end
end
