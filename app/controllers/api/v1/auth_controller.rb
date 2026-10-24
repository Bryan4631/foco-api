module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: %i[logout me]

      # POST /api/v1/auth/register
      def register
        user = User.create!(register_params)
        render json: auth_payload(user), status: :created
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email].to_s.strip.downcase)
        if user&.authenticate(params[:password].to_s)
          render json: auth_payload(user), status: :ok
        else
          render_unauthorized("Correo o contraseña incorrectos")
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        RevokedToken.revoke!(current_token_payload)
        head :no_content
      end

      # GET /api/v1/me
      def me
        render json: { user: user_json(current_user) }
      end

      private

      def register_params
        params.permit(:nombre, :email, :password)
      end

      def auth_payload(user)
        token, payload = JsonWebToken.encode(user)
        { token: token, expires_at: Time.zone.at(payload[:exp]).iso8601, user: user_json(user) }
      end

      # Nunca se expone password_digest
      def user_json(user)
        user.as_json(only: %i[id nombre email])
      end
    end
  end
end
