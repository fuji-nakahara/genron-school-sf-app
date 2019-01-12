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

ActiveRecord::Schema.define(version: 2019_01_12_090152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "students", force: :cascade do |t|
    t.string "name", null: false
    t.text "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "original_id", null: false
    t.integer "synopses_count", default: 0, null: false
    t.integer "works_count", default: 0, null: false
    t.index ["original_id"], name: "index_students_on_original_id", unique: true
  end

  create_table "students_terms", id: false, force: :cascade do |t|
    t.bigint "term_id"
    t.bigint "student_id"
    t.index ["student_id"], name: "index_students_terms_on_student_id"
    t.index ["term_id"], name: "index_students_terms_on_term_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.bigint "term_id", null: false
    t.integer "number", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "synopses_count", default: 0, null: false
    t.integer "works_count", default: 0, null: false
    t.date "deadline_date"
    t.date "comment_date"
    t.date "work_deadline_date"
    t.date "work_comment_date"
    t.index ["term_id", "number"], name: "index_subjects_on_term_id_and_number", unique: true
    t.index ["term_id"], name: "index_subjects_on_term_id"
  end

  create_table "synopses", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "student_id", null: false
    t.integer "original_id", null: false
    t.string "title"
    t.text "body"
    t.text "appeal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "selected", default: false, null: false
    t.integer "character_count"
    t.integer "appeal_character_count"
    t.index ["original_id"], name: "index_synopses_on_original_id", unique: true
    t.index ["student_id"], name: "index_synopses_on_student_id"
    t.index ["subject_id"], name: "index_synopses_on_subject_id"
  end

  create_table "terms", force: :cascade do |t|
  end

  create_table "works", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "student_id", null: false
    t.integer "original_id", null: false
    t.string "title"
    t.text "body"
    t.text "appeal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score", default: 0, null: false
    t.integer "character_count"
    t.integer "appeal_character_count"
    t.index ["original_id"], name: "index_works_on_original_id", unique: true
    t.index ["student_id"], name: "index_works_on_student_id"
    t.index ["subject_id"], name: "index_works_on_subject_id"
  end

  add_foreign_key "subjects", "terms"
  add_foreign_key "synopses", "students"
  add_foreign_key "synopses", "subjects"
  add_foreign_key "works", "students"
  add_foreign_key "works", "subjects"
end
