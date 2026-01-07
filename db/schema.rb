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

ActiveRecord::Schema[8.1].define(version: 2026_01_07_230248) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "artists", force: :cascade do |t|
    t.datetime "audiodb_enriched_at"
    t.string "audiodb_id"
    t.string "audiodb_status"
    t.string "banner_url"
    t.text "biography"
    t.string "country"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "disbanded_year"
    t.string "facebook_url"
    t.string "fanart_url"
    t.integer "formed_year"
    t.string "genre"
    t.string "image_url"
    t.string "logo_url"
    t.string "music_style"
    t.string "name", null: false
    t.string "thumbnail_url"
    t.string "twitter_handle"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["audiodb_id"], name: "index_artists_on_audiodb_id"
    t.index ["audiodb_status"], name: "index_artists_on_audiodb_status"
    t.index ["genre"], name: "index_artists_on_genre"
    t.index ["name"], name: "index_artists_on_name"
  end

  create_table "concerts", force: :cascade do |t|
    t.bigint "artist_id", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at"
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.decimal "price", precision: 10, scale: 2
    t.string "price_currency", default: "EUR"
    t.datetime "starts_at", null: false
    t.string "ticket_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "venue_address"
    t.string "venue_name", null: false
    t.index ["artist_id"], name: "index_concerts_on_artist_id"
    t.index ["city"], name: "index_concerts_on_city"
    t.index ["latitude", "longitude"], name: "index_concerts_on_latitude_and_longitude"
    t.index ["starts_at"], name: "index_concerts_on_starts_at"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti", unique: true
  end

  create_table "user_artists", force: :cascade do |t|
    t.bigint "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["artist_id"], name: "index_user_artists_on_artist_id"
    t.index ["user_id", "artist_id"], name: "index_user_artists_on_user_id_and_artist_id", unique: true
    t.index ["user_id"], name: "index_user_artists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.text "spotify_access_token"
    t.text "spotify_refresh_token"
    t.datetime "spotify_token_expires_at"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "concerts", "artists"
  add_foreign_key "user_artists", "artists"
  add_foreign_key "user_artists", "users"
end
