module Api
  module V1
    class TareasController < BaseController
      before_action :set_tarea, only: [ :show, :update, :destroy ]

      # GET /api/v1/tareas
      def index
        tareas = ver_todos? ? Tarea.all : Tarea.joins(:area).where(areas: { user_id: current_user.id })
        render json: tareas.order(created_at: :desc), status: :ok
      end

      # GET /api/v1/tareas/:id
      def show
        authorize!(@tarea, :show)
        render json: @tarea, status: :ok
      end

      # POST /api/v1/tareas
      def create
        area = area_propia!(params[:tarea][:area_id])
        tarea = area.tareas.new(tarea_params.except(:area_id))

        if tarea.save
          render json: tarea, status: :created
        else
          render json: { errors: tarea.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: { area: [ "no válida o no te pertenece" ] } }, status: :unprocessable_entity
      end

      # PATCH/PUT /api/v1/tareas/:id
      def update
        authorize!(@tarea, :update)
        area_propia!(params[:tarea][:area_id]) if params[:tarea][:area_id].present?

        if @tarea.update(tarea_params)
          render json: @tarea, status: :ok
        else
          render json: { errors: @tarea.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: { area: [ "no válida o no te pertenece" ] } }, status: :unprocessable_entity
      end

      # DELETE /api/v1/tareas/:id
      def destroy
        authorize!(@tarea, :destroy)
        @tarea.destroy
        head :no_content
      end

      private

      def set_tarea
        @tarea = Tarea.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Tarea no encontrada" }, status: :not_found
      end

      # Se agrega :descripcion: el modelo la tenía pero la API no la dejaba guardar.
      def tarea_params
        params.require(:tarea).permit(:titulo, :descripcion, :fecha_limite, :prioridad, :estado, :estimado_minutos, :area_id)
      end
    end
  end
end
