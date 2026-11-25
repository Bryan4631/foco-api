module Api
  module V1
    # Gestión de usuarios y roles. Solo el administrador (UserPolicy) → los demás reciben 403.
    class UsuariosController < BaseController
      # GET /api/v1/usuarios
      def index
        authorize!(User, :index)
        usuarios = User.order(:id)
        render json: usuarios.map { |u| usuario_json(u) }, status: :ok
      end

      # PATCH/PUT /api/v1/usuarios/:id   body: { "usuario": { "rol": "admin" } }
      def update
        authorize!(User, :update)
        usuario = User.find(params[:id])

        # Regla de negocio: el admin no puede quitarse su propio rol (se quedaría sin admins).
        if usuario.id == current_user.id && rol_param != "admin"
          return render_field_error(:rol, "no puedes quitarte tu propio rol de administrador")
        end

        usuario.update!(rol: rol_param)
        render json: usuario_json(usuario), status: :ok
      end

      private

      def rol_param
        params.require(:usuario).require(:rol)
      end

      def usuario_json(usuario)
        usuario.as_json(only: %i[id nombre email rol])
      end
    end
  end
end
