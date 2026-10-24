module Api
  module V1
    # Base de todos los recursos protegidos: exige un token JWT válido.
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      def render_field_error(field, message)
        render json: { error: "Datos inválidos", errors: { field => [message] } }, status: 422
      end
    end
  end
end
