require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test "tag value should exist" do
    tag = Tag.new
    
    assert tag.invalid?
    
    tag.value = rand.to_s + "_tag"
    assert tag.valid?
  end
  
  test "tag value should be unique" do
    tag = Tag.new(:value => tags(:two).value)
    
    assert tag.invalid?
  end
end
