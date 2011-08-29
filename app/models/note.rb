class Note < ActiveRecord::Base
  has_many :note_tags
  has_many :tags, :through => :note_tags
  
  belongs_to :user
  
  validates :title, :presence => true, :length => { :within => 5..140 }
  validates :content, :length => { :maximum => 1000 }
  
	default_scope :order => "created_at DESC" #, :conditions => "is_deleted = false"
  scope :public_notes, where(:is_private => :false, :is_deleted => :false)
  scope :active_notes, where(:is_deleted => :false)
  scope :recently_added, lambda { |hours| where('updated_at > ? and is_private = 0 and is_deleted = 0', hours.hours.ago) }
  #scope :any_status, lambda { where('is_deleted = true or is_deleted = false') }
  
  def add_note_to_user(user)
    return if !save
    user.notes << self
    user.update_counters('note')
  end
  
  def delete_from_user(user)
    self.is_deleted = true
    return (save and user.update_counters('note', false))
  end
end
