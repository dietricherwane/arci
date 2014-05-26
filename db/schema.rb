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

ActiveRecord::Schema.define(version: 20140513165948) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archive_boxes", force: true do |t|
    t.string   "name"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "blocks", force: true do |t|
    t.string   "name"
    t.integer  "shaft_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "books", force: true do |t|
    t.string   "code"
    t.string   "title"
    t.text     "description"
    t.integer  "total_quantity"
    t.integer  "quantity_in_stock"
    t.integer  "category_id"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "block_id"
    t.integer  "consultant_id"
    t.integer  "archive_box_id"
    t.string   "geographic_position"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
    t.date     "publication_date"
  end

  create_table "books_demands", id: false, force: true do |t|
    t.integer  "book_id"
    t.integer  "demand_id"
    t.boolean  "on_hold"
    t.boolean  "in_progress"
    t.boolean  "validated"
    t.boolean  "returned"
    t.boolean  "book_damaged"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unavailable"
    t.boolean  "book_left"
    t.boolean  "taken"
    t.text     "comments"
    t.integer  "user_id"
    t.integer  "validated_by"
    t.integer  "taken_by"
    t.integer  "returned_by"
    t.integer  "unavailable_by"
    t.integer  "book_damaged_by"
    t.integer  "damaged_by"
    t.datetime "unavailable_by_at"
    t.datetime "validated_at"
    t.datetime "book_left_at"
    t.datetime "taken_by_at"
    t.datetime "returned_at"
    t.datetime "book_damaged_at"
    t.datetime "returned_by_at"
    t.datetime "book_damaged_by_at"
    t.datetime "validated_by_at"
  end

  add_index "books_demands", ["book_id", "demand_id"], name: "index_books_demands_on_book_id_and_demand_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_code", limit: 3
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "clients", force: true do |t|
    t.string   "name"
    t.integer  "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consultants", force: true do |t|
    t.string   "name"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "demands", force: true do |t|
    t.integer  "user_id"
    t.datetime "expires_on"
    t.boolean  "on_hold"
    t.boolean  "in_progress"
    t.boolean  "validated"
    t.boolean  "returned"
    t.boolean  "book_damaged"
    t.boolean  "troubles_in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unavailable"
    t.boolean  "book_left"
    t.boolean  "taken"
    t.integer  "validated_by"
    t.integer  "taken_by"
    t.integer  "returned_by"
    t.integer  "unavailable_by"
    t.integer  "book_damaged_by"
    t.integer  "damaged_by"
    t.datetime "validated_by_at"
    t.datetime "unavailable_by_at"
    t.datetime "validated_at"
    t.datetime "book_left_at"
    t.datetime "taken_by_at"
    t.datetime "returned_at"
    t.datetime "book_damaged_at"
    t.datetime "returned_by_at"
    t.datetime "book_damaged_by_at"
  end

  create_table "departments", force: true do |t|
    t.string   "name"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "parameters", force: true do |t|
    t.integer  "expires_in"
    t.integer  "notifies_in"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shortcut"
    t.boolean  "published"
  end

  create_table "qualifications", force: true do |t|
    t.string   "label"
    t.integer  "department_id"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "reservations", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reserved_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shafts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "firstname"
    t.string   "lastname"
    t.integer  "phone_number"
    t.integer  "mobile_number"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.integer  "qualification_id"
    t.integer  "profile_id"
    t.boolean  "published"
    t.integer  "department_id"
    t.integer  "user_id"
    t.boolean  "can_validate"
    t.integer  "created_by"
    t.integer  "update_by"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
