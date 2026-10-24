class CreateTareas < ActiveRecord::Migration[7.1]
  def change
    create_table :tareas do |t|
      t.references :area, null: false, foreign_key: true
      t.string :titulo, null: false
      t.text :descripcion
      t.date :fecha_limite
      t.string :prioridad, null: false, default: "media"
      t.string :estado, null: false, default: "pendiente"
      t.integer :estimado_minutos
      t.timestamps
      t.check_constraint "prioridad IN ('baja','media','alta')", name: "tareas_prioridad_check"
      t.check_constraint "estado IN ('pendiente','en_curso','hecha')", name: "tareas_estado_check"
      t.check_constraint "estimado_minutos IS NULL OR estimado_minutos > 0", name: "tareas_estimado_check"
    end
    add_index :tareas, :estado
    add_index :tareas, :fecha_limite
  end
end
