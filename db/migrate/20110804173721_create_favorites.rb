class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :user_id
      t.integer :bookmark_id
      t.boolean :is_private, :default => 0, :null => false

      t.timestamps
    end
    
    add_index :favorites, ["user_id", "bookmark_id"]
  end
end
