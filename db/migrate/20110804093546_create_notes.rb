class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer  :user_id
      t.string   :title, :limit => 140, :null => false
      t.string   :content, :limit => 1000
      t.boolean  :is_private, :default => 0, :null => false
      t.boolean  :is_deleted, :default => 0

      t.timestamps
    end
    
    add_index :notes, ["user_id"]
  end
end
