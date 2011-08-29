class CreateNoteTagsJoin < ActiveRecord::Migration
  def change
    create_table :note_tags do |t|
      t.integer  :note_id
      t.integer  :tag_id
    end
    
    add_index :note_tags, ["note_id", "tag_id"]
  end
end
