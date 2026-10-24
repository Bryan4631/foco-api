class CreateBloques < ActiveRecord::Migration[7.1]
  def change
    create_table :bloques do |t|
      t.references :area, null: false, foreign_key: true
      t.string :titulo, null: false
      t.integer :dia_semana, null: false
      t.string :hora_inicio, null: false, limit: 5
      t.string :hora_fin, null: false, limit: 5
      t.timestamps
      t.check_constraint "dia_semana BETWEEN 1 AND 7", name: "bloques_dia_check"
      t.check_constraint "hora_inicio ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'", name: "bloques_inicio_check"
      t.check_constraint "hora_fin ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'", name: "bloques_fin_check"
      t.check_constraint "hora_fin > hora_inicio", name: "bloques_orden_check"
    end
    add_index :bloques, [:area_id, :dia_semana]
  end
end
