module Api
  module V1
    class AreasController < BaseController
      before_action :set_area, only: [ :show, :update, :destroy ]

      # GET /api/v1/areas
      def index
        areas = ver_todos? ? Area.all : current_user.areas
        render json: areas.order(created_at: :desc), status: :ok
      end

      # GET /api/v1/areas/:id
      def show
        authorize!(@area, :show)
        render json: @area, status: :ok
      end

      # POST /api/v1/areas
      def create
        area = current_user.areas.new(area_params)

        if area.save
          render json: area, status: :created
        else
          render json: { errors: area.errors.messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/areas/:id
      def update
        authorize!(@area, :update)

        if @area.update(area_params)
          render json: @area, status: :ok
        else
          render json: { errors: @area.errors.messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/areas/:id
      def destroy
        authorize!(@area, :destroy)

        if @area.destroy
          head :no_content
        else
          render json: { error: "No se puede eliminar el área porque tiene tareas asociadas." }, status: :unprocessable_entity
        end
      end

      private

      # Busca el área por id (404 si no existe). Quién puede tocarla lo decide AreaPolicy (403).
      def set_area
        @area = Area.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Área no encontrada" }, status: :not_found
      end

      def area_params
        params.require(:area).permit(:nombre, :color, :tipo)
      end
    end
  end
end
