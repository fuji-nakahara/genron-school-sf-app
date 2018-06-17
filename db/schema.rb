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

ActiveRecord::Schema.define(version: 2018_06_17_080806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "students", force: :cascade do |t|
    t.string "name", null: false
    t.text "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "wp_id", null: false
    t.index ["wp_id"], name: "index_students_on_wp_id", unique: true
  end

  create_table "students_terms", id: false, force: :cascade do |t|
    t.bigint "term_id"
    t.bigint "student_id"
    t.index ["student_id"], name: "index_students_terms_on_student_id"
    t.index ["term_id"], name: "index_students_terms_on_term_id"
  end

  create_table "terms", force: :cascade do |t|
  end

end
