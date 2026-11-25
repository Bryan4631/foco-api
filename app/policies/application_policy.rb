# Autorización propia (sin gema), inspirada en el patrón de Pundit:
# una "policy" por recurso que responde si un usuario puede hacer una acción sobre un registro.
#
# Regla base:
#   - el DUEÑO del registro puede verlo, editarlo y eliminarlo (restricción por propiedad)
#   - el ADMIN puede hacerlo sobre cualquier registro (restricción por rol)
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    owner_or_admin?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  private

  def owner_or_admin?
    user.admin? || record.user_id == user.id
  end
end
