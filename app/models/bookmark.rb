class Bookmark < ActiveRecord::Base
  has_many :bookmark_users
  has_many :users, :through => :bookmark_users
  accepts_nested_attributes_for :bookmark_users
  
  has_many :bookmark_tags
  has_many :tags, :through => :bookmark_tags
  
  before_validation :add_http_if_missing
  
  validates :title, :length => { :maximum => 140 }
  validates :description, :length => { :maximum => 500 }
  
  URL_REGEX = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  validates :url, :format => {
    :with => URL_REGEX,
    :message => 'must be a valid URL'
  }, :length => { :maximum => 500 }, :presence => true
  
	default_scope :order => "created_at DESC"
  scope :public_bookmarks, where(:is_private => :false)
  scope :recently_added, lambda { |hours| where('updated_at > ? and save_count > 0', hours.hours.ago) }
  scope :n_save_count, lambda { |count| where('save_count > ?', count) }
  
  def check_url
    add_http_if_missing
    if existing_bookmark = Bookmark.get_bookmark_by_url(url)
      self.title = existing_bookmark.title
      self.description = existing_bookmark.description
        return true
    else
      begin
        agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari'}
        page = agent.get(url)
        desc = page.search('//meta[@name="description"]').first
        self.description = desc['content'].strip if !desc.nil?
        self.title = page.title.strip
        return true
      rescue Exception => ex
        logger.error "Check Url Error: " + ex.to_s
        return false
      end
    end
  end
  
  def add_bookmark_to_user(bookmark_user)
    if existing_bookmark = Bookmark.get_bookmark_by_url(url)
      existing_bookmark.save_count += 1
      existing_bookmark.bookmark_users << bookmark_user
      existing_bookmark.users << bookmark_user.user

      return (existing_bookmark.save and bookmark_user.user.update_counters('bookmark'))
    end
    
    self.created_by = bookmark_user.user_id
    return (save and bookmark_user.user.update_counters('bookmark'))
  end
  
  def delete_from_user(user)
    self.decrement!(:save_count)
    
    user.bookmark_users.find_by_bookmark_id(self.id).update_attributes(:is_deleted => 1)
    user.update_counters('bookmark', false)
  end
  
  def self.get_bookmark_by_url(url)
    #check the url w and w/o www, http, https
    #First clean http/https/www from the original url
    url_tmp = url
    url_tmp = url.sub('https://', '') if !url.scan("https://").empty?
    url_tmp = url.sub('http://', '') if !url.scan("http://").empty?
    
    url_tmp = url_tmp.sub('www.', '') if !url_tmp.scan("www.").empty?

    return Bookmark.where("url = '#{url_tmp}' OR url = 'www.#{url_tmp}' OR url = 'http://#{url_tmp}' OR url = 'https://#{url_tmp}' 
      OR url = 'http://www.#{url_tmp}' OR url = 'https://www.#{url_tmp}'").first
  end

  def self.get_active_bookmark(id)
    Bookmark.where("save_count > 0 and id = #{id}").first
  end
    
  protected
  
  def add_http_if_missing
    return if self.url.blank?
    
    if self.url.scan("http://").empty?
      self.url = "http://" + self.url.strip
    end
  end
end
