class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :limit => 50, :null => false
      t.string :email, :limit => 255, :null => false
      t.string :hashed_password, :null => false
      t.string :salt, :null => false
      t.boolean  :is_deleted, :default => 0

      t.timestamps
    end
  end
end
