# Verifica en la API (no solo ocultando botones) si el usuario puede hacer una acción.
#   authorize!(@area, :update)   -> si no puede, responde 403 Forbidden
module Authorization
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    rescue_from NotAuthorizedError do
      render json: { error: "No tienes permiso para realizar esta acción" }, status: :forbidden
    end
  end

  private

  # record puede ser una instancia (Area) o una clase (User)
  def authorize!(record, action)
    klass = record.is_a?(Class) ? record : record.class
    policy = "#{klass.name}Policy".constantize.new(current_user, record)
    raise NotAuthorizedError unless policy.public_send("#{action}?")
  end
end
