class CreateAreas < ActiveRecord::Migration[7.1]
  def change
    create_table :areas do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nombre, null: false
      t.string :tipo, null: false, default: "estudio"
      t.string :color, null: false, default: "#2563eb"
      t.timestamps
      t.check_constraint "tipo IN ('estudio','emprendimiento','trabajo','personal')", name: "areas_tipo_check"
    end
    add_index :areas, [:user_id, :nombre], unique: true
  end
end
