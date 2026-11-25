module Api
  module V1
    # Base de todos los recursos protegidos: exige un token JWT válido (401 si no lo hay).
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      def render_field_error(field, message)
        render json: { error: "Datos inválidos", errors: { field => [ message ] } }, status: 422
      end

      # El admin puede pedir los datos de todos los usuarios con ?todos=true.
      # Un usuario normal siempre ve solo lo suyo (el parámetro se ignora).
      def ver_todos?
        current_user.admin? && params[:todos] == "true"
      end

      # Área a la que el usuario quiere asociar una tarea/bloque.
      # Debe ser suya: si no existe o es ajena, la acción responde 422 (ver rescue en cada controller).
      def area_propia!(id)
        current_user.areas.find(id)
      end
    end
  end
end
