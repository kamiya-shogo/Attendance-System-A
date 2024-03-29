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

ActiveRecord::Schema.define(version: 20221028123547) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attendances_request_superior"
    t.string "attendances_approval_status"
    t.boolean "attendances_approval_check", default: false
    t.datetime "edit_started_at"
    t.datetime "edit_finished_at"
    t.datetime "begin_started"
    t.datetime "begin_finished"
    t.datetime "scheduled_end_time"
    t.boolean "next_day", default: false
    t.boolean "overtime_next_day", default: false
    t.string "business_process_content"
    t.string "overtime_request_superior"
    t.string "overtime_request_status"
    t.boolean "overtime_check", default: false
    t.string "one_month_request_superior"
    t.string "one_month_request_status"
    t.string "one_month_approval_status"
    t.boolean "one_month_approval_check", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "base_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2022-10-24 23:00:00"
    t.datetime "work_time", default: "2022-10-24 22:30:00"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time", default: "2022-10-25 00:00:00"
    t.datetime "designated_work_end_time", default: "2022-10-25 09:00:00"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
