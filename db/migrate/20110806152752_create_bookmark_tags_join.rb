class CreateBookmarkTagsJoin < ActiveRecord::Migration
  def change
    create_table :bookmark_tags do |t|
      t.integer  :bookmark_id
      t.integer  :tag_id
      t.boolean  :is_private, :default => 0, :null => false
    end
    
    add_index :bookmark_tags, ["bookmark_id", "tag_id"]
  end
end
