class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string  :value, :null => false, :limit => 140
      t.string  :slug,  :null => false, :limit => 200
      t.integer :count, :default => 1

      t.timestamps
    end
  end
end
