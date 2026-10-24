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

ActiveRecord::Schema[8.1].define(version: 2026_10_24_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "areas", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "nombre", null: false
    t.string "tipo", default: "estudio", null: false
    t.string "color", default: "#2563eb", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "nombre"], name: "index_areas_on_user_id_and_nombre", unique: true
    t.index ["user_id"], name: "index_areas_on_user_id"
    t.check_constraint "tipo::text = ANY (ARRAY['estudio'::character varying, 'emprendimiento'::character varying, 'trabajo'::character varying, 'personal'::character varying]::text[])", name: "areas_tipo_check"
  end

  create_table "bloques", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.string "titulo", null: false
    t.integer "dia_semana", null: false
    t.string "hora_inicio", limit: 5, null: false
    t.string "hora_fin", limit: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "dia_semana"], name: "index_bloques_on_area_id_and_dia_semana"
    t.index ["area_id"], name: "index_bloques_on_area_id"
    t.check_constraint "dia_semana >= 1 AND dia_semana <= 7", name: "bloques_dia_check"
    t.check_constraint "hora_fin::text > hora_inicio::text", name: "bloques_orden_check"
    t.check_constraint "hora_fin::text ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'::text", name: "bloques_fin_check"
    t.check_constraint "hora_inicio::text ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'::text", name: "bloques_inicio_check"
  end

  create_table "tareas", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.string "titulo", null: false
    t.text "descripcion"
    t.date "fecha_limite"
    t.string "prioridad", default: "media", null: false
    t.string "estado", default: "pendiente", null: false
    t.integer "estimado_minutos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_tareas_on_area_id"
    t.index ["estado"], name: "index_tareas_on_estado"
    t.index ["fecha_limite"], name: "index_tareas_on_fecha_limite"
    t.check_constraint "estado::text = ANY (ARRAY['pendiente'::character varying, 'en_curso'::character varying, 'hecha'::character varying]::text[])", name: "tareas_estado_check"
    t.check_constraint "estimado_minutos IS NULL OR estimado_minutos > 0", name: "tareas_estimado_check"
    t.check_constraint "prioridad::text = ANY (ARRAY['baja'::character varying, 'media'::character varying, 'alta'::character varying]::text[])", name: "tareas_prioridad_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "areas", "users"
  add_foreign_key "bloques", "areas"
  add_foreign_key "tareas", "areas"
end
