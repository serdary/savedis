class CreateBookmarkUsersJoin < ActiveRecord::Migration
  def change
    create_table :bookmark_users do |t|
      t.integer  :bookmark_id
      t.integer  :user_id
      t.string   :title, :limit => 140
      t.string   :description, :limit => 500
      t.boolean  :is_private, :default => 0, :null => false
      t.boolean  :is_deleted, :default => 0
      
      t.timestamps
    end
    
    add_index :bookmark_users, ["bookmark_id", "user_id"]
  end
end
