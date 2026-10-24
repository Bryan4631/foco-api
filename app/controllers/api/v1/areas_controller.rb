module Api
  module V1
    class AreasController < BaseController
      before_action :set_area, only: [:show, :update, :destroy]

      # GET /api/v1/areas
      def index
        areas = current_user.areas.order(created_at: :desc)
        render json: areas, status: :ok
      end

      # GET /api/v1/areas/:id
      def show
        render json: @area, status: :ok
      end

      # POST /api/v1/areas
      def create
        area = current_user.areas.new(area_params)

        if area.save
          render json: area, status: :created
        else
          # Devuelve los errores de validación en formato JSON para el 422
          render json: { errors: area.errors.messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/areas/:id
      def update
        if @area.update(area_params)
          render json: @area, status: :ok
        else
          render json: { errors: @area.errors.messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/areas/:id
      def destroy
        if @area.destroy
          head :no_content
        else
          render json: { error: "No se puede eliminar el área porque tiene tareas asociadas." }, status: :unprocessable_entity
        end
      end

      private

      def set_area
        # Busca el área solo dentro de las áreas del usuario actual (Seguridad)
        @area = current_user.areas.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Área no encontrada' }, status: :not_found
      end

      def area_params
        # Aquí está la magia: permite que Rails acepte nombre, color y tipo
        params.require(:area).permit(:nombre, :color, :tipo)
      end
    end
  end
end