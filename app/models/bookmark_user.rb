class BookmarkUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :bookmark
    
  validates :title, :length => { :maximum => 140 }
  validates :description, :length => { :maximum => 500 }
    
  default_scope :order => "updated_at DESC"
end