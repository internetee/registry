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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "epp_logs", force: true do |t|
    t.text     "request"
    t.text     "response"
    t.string   "request_command"
    t.string   "request_object"
    t.boolean  "request_successful"
    t.string   "api_user_name"
    t.string   "api_user_registrar"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repp_logs", force: true do |t|
    t.string   "request_path"
    t.string   "request_method"
    t.text     "request_params"
    t.text     "response"
    t.string   "response_code"
    t.string   "api_user_name"
    t.string   "api_user_registrar"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
