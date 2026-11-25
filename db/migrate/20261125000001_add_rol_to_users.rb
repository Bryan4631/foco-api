# Tarea 2: cada usuario tiene un rol persistido en PostgreSQL.
# Roles: "usuario" (por defecto) y "admin".
class AddRolToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :rol, :string, null: false, default: "usuario"
    add_check_constraint :users, "rol IN ('usuario', 'admin')", name: "users_rol_check"
    add_index :users, :rol
  end
end
