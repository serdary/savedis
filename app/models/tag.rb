class Tag < ActiveRecord::Base  
  has_many :bookmark_tags
  has_many :bookmarks, :through => :bookmark_tags

  has_many :note_tags
  has_many :notes, :through => :note_tags

  validates :value, :presence => true, :length => { :within => 1..140 }, :uniqueness => {:case_sensitive => false}
  
  scope :n_count, lambda { |count| where('count > ?', count) }
  
  def self.get_tag_by_value(tag_value)
    return Tag.find_by_slug(self.generate_slug(tag_value))
  end
  
  def self.create_new(tag_value)
    return Tag.new(:value => tag_value, :slug => self.generate_slug(tag_value))
  end
  
  def self.generate_slug(tag_value)
    return tag_value.parameterize
  end
  
  def self.add_tags_to_parent(parent_obj, tag_values)
    return if tag_values.blank?
    
    tag_values = get_valid_tags_arr(tag_values)
    
    tag_values.each do |tag_value|
      if tag = Tag.get_tag_by_value(tag_value)
        tag.increment!(:count)
        parent_obj.tags << tag
      else
        parent_obj.tags << Tag.create_new(tag_value)
      end
    end
  end
  
  def self.update_parent_tags(parent_obj, tag_values)
    tag_values = get_valid_tags_arr(tag_values) if !tag_values.blank?
    
    parent_obj.tags.each do |t|
      if tag_values.include?(t.value)
        tag_values.delete(t.value)
      else
        t.decrement!(:count)
        if parent_obj.class == Bookmark
          parent_obj.bookmark_tags.find_by_tag_id(t.id).delete
        elsif parent_obj.class == Note
          parent_obj.note_tags.find_by_tag_id(t.id).delete
        end
      end
    end
    
    return if tag_values.blank?
    
    add_tags_to_parent(parent_obj, tag_values.join(','))
  end
  
  def self.delete_tags_from_parent(parent_obj)
    parent_obj.tags.each do |tag|
      tag.decrement!(:count)
      
      if parent_obj.class == Bookmark
        parent_obj.bookmark_tags.find_by_tag_id(tag.id).delete
      elsif parent_obj.class == Note
        parent_obj.note_tags.find_by_tag_id(tag.id).delete
      end
    end
  end
  
  def self.get_valid_tags_arr(tag_values)
    return tag_values.strip.split(',').uniq
  end
  
  def self.app_tags
    return Tag.where("count > ?", 0).order("count DESC, created_at DESC").limit(10)
  end
end