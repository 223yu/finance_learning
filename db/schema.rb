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

ActiveRecord::Schema.define(version: 2021_08_04_004413) do

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "year", null: false
    t.integer "code", null: false
    t.string "name", null: false
    t.integer "total_account", null: false
    t.integer "opening_balance_1", default: 0, null: false
    t.integer "debit_balance_1", default: 0, null: false
    t.integer "credit_balance_1", default: 0, null: false
    t.integer "opening_balance_2", default: 0, null: false
    t.integer "debit_balance_2", default: 0, null: false
    t.integer "credit_balance_2", default: 0, null: false
    t.integer "opening_balance_3", default: 0, null: false
    t.integer "debit_balance_3", default: 0, null: false
    t.integer "credit_balance_3", default: 0, null: false
    t.integer "opening_balance_4", default: 0, null: false
    t.integer "debit_balance_4", default: 0, null: false
    t.integer "credit_balance_4", default: 0, null: false
    t.integer "opening_balance_5", default: 0, null: false
    t.integer "debit_balance_5", default: 0, null: false
    t.integer "credit_balance_5", default: 0, null: false
    t.integer "opening_balance_6", default: 0, null: false
    t.integer "debit_balance_6", default: 0, null: false
    t.integer "credit_balance_6", default: 0, null: false
    t.integer "opening_balance_7", default: 0, null: false
    t.integer "debit_balance_7", default: 0, null: false
    t.integer "credit_balance_7", default: 0, null: false
    t.integer "opening_balance_8", default: 0, null: false
    t.integer "debit_balance_8", default: 0, null: false
    t.integer "credit_balance_8", default: 0, null: false
    t.integer "opening_balance_9", default: 0, null: false
    t.integer "debit_balance_9", default: 0, null: false
    t.integer "credit_balance_9", default: 0, null: false
    t.integer "opening_balance_10", default: 0, null: false
    t.integer "debit_balance_10", default: 0, null: false
    t.integer "credit_balance_10", default: 0, null: false
    t.integer "opening_balance_11", default: 0, null: false
    t.integer "debit_balance_11", default: 0, null: false
    t.integer "credit_balance_11", default: 0, null: false
    t.integer "opening_balance_12", default: 0, null: false
    t.integer "debit_balance_12", default: 0, null: false
    t.integer "credit_balance_12", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "year", "code"], name: "index_accounts_on_user_id_and_year_and_code", unique: true
  end

  create_table "contents", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "user_limited", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journals", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "debit_id", null: false
    t.integer "credit_id", null: false
    t.date "date", null: false
    t.integer "amount", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "learnings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "content_id", null: false
    t.boolean "end_learning", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
