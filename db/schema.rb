# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20140908122624) do

  create_table "flickr_pictures", :force => true do |t|
    t.string   "photo_url"
    t.string   "title"
    t.integer  "picturable_id"
    t.string   "picturable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "flickr_pictures", ["picturable_id", "picturable_type"], :name => "index_flickr_pictures_on_picturable_id_and_picturable_type"

  create_table "localities", :force => true do |t|
    t.integer  "pass_id"
    t.integer  "municipality_id"
    t.integer  "fraction_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "localitiable_id"
    t.string   "localitiable_type"
  end

  add_index "localities", ["localitiable_id", "localitiable_type"], :name => "index_localities_on_localitiable_id_and_localitiable_type"

  create_table "passes", :force => true do |t|
    t.string   "name"
    t.string   "locality"
    t.integer  "altitude"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "name_encoded"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "passes", ["name_encoded"], :name => "index_passes_on_name_encoded"

  create_table "user_sessions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

end
