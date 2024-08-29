# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "epp_logs", force: :cascade do |t|
    t.text "request"
    t.text "response"
    t.string "request_command", limit: 255
    t.string "request_object"
    t.boolean "request_successful"
    t.string "api_user_name", limit: 255
    t.string "api_user_registrar", limit: 255
    t.string "ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uuid"
    t.index ["uuid"], name: "epp_logs_uuid"
  end

  create_table "repp_logs", force: :cascade do |t|
    t.string "request_path", limit: 255
    t.string "request_method", limit: 255
    t.text "request_params"
    t.text "response"
    t.string "response_code", limit: 255
    t.string "api_user_name", limit: 255
    t.string "api_user_registrar", limit: 255
    t.string "ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uuid"
    t.index ["uuid"], name: "repp_logs_uuid"
  end

end
