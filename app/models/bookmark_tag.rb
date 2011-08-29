class BookmarkTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :bookmark
end