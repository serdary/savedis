class AddCreatedByToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :created_by, :integer
  end
end
