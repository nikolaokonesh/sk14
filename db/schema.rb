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

ActiveRecord::Schema[8.2].define(version: 2026_05_02_090000) do
  create_table "access_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["token"], name: "index_access_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_access_tokens_on_user_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "advertisements", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "paid_until"
    t.string "theme", default: "sunset", null: false
    t.boolean "top_placement", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_advertisements_on_active"
    t.index ["created_at"], name: "index_advertisements_on_created_at"
    t.index ["paid_until"], name: "index_advertisements_on_paid_until"
    t.index ["top_placement"], name: "index_advertisements_on_top_placement"
  end

  create_table "entries", force: :cascade do |t|
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "entryable_id", null: false
    t.string "entryable_type", null: false
    t.integer "images_count", default: 0
    t.integer "parent_id"
    t.integer "position", default: 0
    t.integer "root_id"
    t.string "title", limit: 500
    t.boolean "trash", default: false
    t.datetime "trash_data"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_entries_on_created_at"
    t.index ["entryable_type", "entryable_id"], name: "index_entries_on_entryable"
    t.index ["parent_id"], name: "index_entries_on_parent_id"
    t.index ["root_id"], name: "index_entries_on_root_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "entry_reads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "entry_id", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["entry_id"], name: "index_entry_reads_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_entry_reads_on_user_id_and_entry_id", unique: true
    t.index ["user_id"], name: "index_entry_reads_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.json "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "posts", force: :cascade do |t|
    t.string "afisha_status"
    t.datetime "created_at", null: false
    t.datetime "event_date"
    t.integer "event_duration", default: 1
    t.datetime "finished_at"
    t.boolean "is_afisha", default: false, null: false
    t.boolean "manual_finished", default: false
    t.json "setting", default: {}, null: false
    t.json "tags_listing", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["afisha_status"], name: "index_posts_on_afisha_status"
    t.index ["event_date"], name: "index_posts_on_event_date"
    t.index ["finished_at"], name: "index_posts_on_finished_at"
    t.index ["is_afisha"], name: "index_posts_on_is_afisha"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.integer "followers_count", default: 0
    t.string "last_name"
    t.string "otp_secret"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "access_tokens", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "entries", "entries", column: "parent_id"
  add_foreign_key "entries", "entries", column: "root_id"
  add_foreign_key "entries", "users"
  add_foreign_key "entry_reads", "entries"
  add_foreign_key "entry_reads", "users"
  add_foreign_key "sessions", "users"
end
