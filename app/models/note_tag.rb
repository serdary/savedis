class NoteTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :note
end