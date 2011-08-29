class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :title, :limit => 140, :null => false
      t.string :url, :limit => 255
      t.string :description, :limit => 500
      t.integer :save_count, :default => 1

      t.timestamps
    end
    add_index(:bookmarks, :url, :unique => true)
  end
end
