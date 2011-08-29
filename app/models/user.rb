require 'digest/sha2'

class User < ActiveRecord::Base
  has_many :bookmark_users
  has_many :bookmarks, :through => :bookmark_users
  has_many :public_bookmarks, :through => :bookmark_users, 
           :class_name => "Bookmark", 
           :source => :bookmark, 
           :conditions => ['bookmark_users.is_private = ? and bookmark_users.is_deleted = ?', false, false]
  
  has_many :active_bookmarks, :through => :bookmark_users, 
           :class_name => "Bookmark", 
           :source => :bookmark, 
           :conditions => ['bookmark_users.is_deleted = ?', false]
  
  has_many :notes
  
  USERNAME_REGEX = /^[a-z0-9\-_]+$/i
  validates :username, :presence => true, :uniqueness => {:case_sensitive => false}, :format => { :with => USERNAME_REGEX }, :length => { :within => 1..50}
  
  validates_exclusion_of :username, :in => %w(admin cms status connect press home 
  blog news privacy contact help faq button dev api tools administrator about 
  jobs career beta alpha login logout register join favorite favorites tags tag
  application app bookmarks notes profile sessions session users user ajax 
  400 401 403 404 500)
  
  attr_reader :password
  
  validate :password_must_be_supplied
  
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => true, :uniqueness => {:case_sensitive => false}, :format => { :with => EMAIL_REGEX }, :length => { :maximum => 255 }
  
	scope :valid, where(:is_deleted => false)
    
  def self.authenticate(username, password)
    if user = find_by_username(username)
      if user.hashed_password == hash_password(password, user.salt) and !user.is_deleted
        user
      end
    end
  end
  
  def self.hash_password(password, salt)
    Digest::SHA2.hexdigest("#{password}_savedis_#{salt}")
  end
  
  def password=(password)
    @password = password
    
    if password.present?
      create_salt
      self.hashed_password = self.class.hash_password(password, salt)
    end
  end
  
  def update_counters(type, increment = true)
    if type == 'bookmark'
      return increment ? self.increment!(:bookmark_count) : self.decrement!(:bookmark_count)
    elsif type == 'note'
      return increment ? self.increment!(:note_count) : self.decrement!(:note_count)
    end
  end
  
  private
  
  def create_salt
    self.salt = "#{rand.to_s} #{Time.now}"
  end

  def password_must_be_supplied
    errors.add(:password, "is required") unless hashed_password.present?
  end

  #TODO: add "user role" functionality to the system
end
