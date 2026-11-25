# Gestión de usuarios: acción restringida por ROL.
# Solo el administrador puede listar usuarios y cambiar el rol de otro.
class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def update?
    user.admin?
  end
end
