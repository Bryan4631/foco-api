module Api
  module V1
    class TareasController < BaseController
      before_action :set_tarea, only: [:show, :update, :destroy]

      # GET /api/v1/tareas
      def index
        tareas = Tarea.joins(:area).where(areas: { user_id: current_user.id }).order(created_at: :desc)
        render json: tareas, status: :ok
      end

      # GET /api/v1/tareas/:id
      def show
        render json: @tarea, status: :ok
      end

      # POST /api/v1/tareas
      def create
        # Busca el área asegurando que sea del usuario actual
        area = current_user.areas.find(params[:tarea][:area_id])
        
        # Creamos la tarea vinculada a esa área
        tarea = area.tareas.new(tarea_params.except(:area_id))

        if tarea.save
          render json: tarea, status: :created
        else
          render json: { errors: tarea.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: { area: ["no válida o no te pertenece"] } }, status: :unprocessable_entity
      end

      # PATCH/PUT /api/v1/tareas/:id
      def update
        if params[:tarea][:area_id].present?
          current_user.areas.find(params[:tarea][:area_id])
        end

        if @tarea.update(tarea_params)
          render json: @tarea, status: :ok
        else
          render json: { errors: @tarea.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: { area: ["no válida o no te pertenece"] } }, status: :unprocessable_entity
      end

      # DELETE /api/v1/tareas/:id
      def destroy
        @tarea.destroy
        head :no_content
      end

      private

      def set_tarea
        @tarea = Tarea.joins(:area).where(areas: { user_id: current_user.id }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tarea no encontrada' }, status: :not_found
      end

      def tarea_params
        params.require(:tarea).permit(:titulo, :fecha_limite, :prioridad, :estado, :estimado_minutos, :area_id)
      end
    end
  end
end