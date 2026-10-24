module Api
  module V1
    class AreasController < BaseController
      before_action :set_area, only: %i[show update destroy]

      # GET /api/v1/areas
      def index
        render json: current_user.areas.order(:nombre).map { |a| area_json(a) }
      end

      # GET /api/v1/areas/:id
      def show
        render json: area_json(@area)
      end

      # POST /api/v1/areas
      def create
        area = current_user.areas.create!(area_params)
        render json: area_json(area), status: :created
      end

      # PATCH/PUT /api/v1/areas/:id
      def update
        @area.update!(area_params)
        render json: area_json(@area)
      end

      # DELETE /api/v1/areas/:id
      # Si el área tiene tareas o bloques, el modelo bloquea el borrado (restrict_with_error).
      def destroy
        if @area.destroy
          head :no_content
        else
          render json: { error: @area.errors.full_messages.to_sentence }, status: 422
        end
      end

      private

      def set_area
        @area = current_user.areas.find(params[:id])
      end

      def area_params
        params.permit(:nombre, :tipo, :color)
      end

      def area_json(area)
        area.as_json(only: %i[id nombre tipo color created_at updated_at])
      end
    end
  end
end
