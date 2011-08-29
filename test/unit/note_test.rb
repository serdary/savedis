require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "title must not be empty" do
    note = Note.new
    
    assert note.invalid?
    assert note.errors[:title].any?
    
    note.title = 'test note'
    assert note.valid?
  end
  
  test "title must be at least 5 chars long" do
    note = Note.new(:title => 'qwe',
                    :content => 'long enough content')
                    
    assert note.invalid?
    
    note.title = 'longer title'
    assert note.valid?
  end
end
