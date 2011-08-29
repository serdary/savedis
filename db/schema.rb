# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110808124421) do

  create_table "bookmark_tags", :force => true do |t|
    t.integer "bookmark_id"
    t.integer "tag_id"
  end

  add_index "bookmark_tags", ["bookmark_id", "tag_id"], :name => "index_bookmark_tags_on_bookmark_id_and_tag_id"

  create_table "bookmark_users", :force => true do |t|
    t.integer  "bookmark_id"
    t.integer  "user_id"
    t.string   "title",       :limit => 140
    t.string   "description", :limit => 500
    t.boolean  "is_private",                 :default => false, :null => false
    t.boolean  "is_deleted",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookmark_users", ["bookmark_id", "user_id"], :name => "index_bookmark_users_on_bookmark_id_and_user_id"

  create_table "bookmarks", :force => true do |t|
    t.string   "title",       :limit => 140
    t.string   "url",                                       :null => false
    t.string   "description", :limit => 500
    t.integer  "save_count",                 :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
  end

  add_index "bookmarks", ["url"], :name => "index_bookmarks_on_url", :unique => true

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "bookmark_id"
    t.boolean  "is_private",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["user_id", "bookmark_id"], :name => "index_favorites_on_user_id_and_bookmark_id"

  create_table "note_tags", :force => true do |t|
    t.integer "note_id"
    t.integer "tag_id"
  end

  add_index "note_tags", ["note_id", "tag_id"], :name => "index_note_tags_on_note_id_and_tag_id"

  create_table "notes", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",      :limit => 140,                     :null => false
    t.string   "content",    :limit => 1000
    t.boolean  "is_private",                 :default => false, :null => false
    t.boolean  "is_deleted",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "tags", :force => true do |t|
    t.string   "value",      :limit => 140,                :null => false
    t.string   "slug",       :limit => 200,                :null => false
    t.integer  "count",                     :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["value"], :name => "index_tags_on_value", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username",        :limit => 50,                    :null => false
    t.string   "email",                                            :null => false
    t.string   "hashed_password",                                  :null => false
    t.string   "salt",                                             :null => false
    t.boolean  "is_deleted",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bookmark_count",                :default => 0
    t.integer  "note_count",                    :default => 0
  end

end
