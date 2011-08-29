class AddBookmarkCountAndNoteCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bookmark_count, :integer, :default => 0
    add_column :users, :note_count, :integer, :default => 0
  end
end
