# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_27_055025) do

  create_table "footprints", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "before"
    t.text "after"
    t.string "action"
    t.string "trackable_type", null: false
    t.bigint "trackable_id", null: false
    t.string "actorable_type"
    t.bigint "actorable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["actorable_type", "actorable_id"], name: "index_footprints_on_actorable_type_and_actorable_id"
    t.index ["trackable_type", "trackable_id"], name: "index_footprints_on_trackable_type_and_trackable_id"
  end

end
