module Api
  module V1
    class TareasController < BaseController
      before_action :set_tarea, only: %i[show update destroy]

      # GET /api/v1/tareas?area_id=1&estado=pendiente&prioridad=alta
      def index
        tareas = current_user.tareas.includes(:area)
        tareas = tareas.where(area_id: params[:area_id]) if params[:area_id].present?
        tareas = tareas.where(estado: params[:estado]) if params[:estado].present?
        tareas = tareas.where(prioridad: params[:prioridad]) if params[:prioridad].present?
        tareas = tareas.order(Arel.sql("tareas.fecha_limite ASC NULLS LAST"), :id)
        render json: tareas.map { |t| tarea_json(t) }
      end

      # GET /api/v1/tareas/:id
      def show
        render json: tarea_json(@tarea)
      end

      # POST /api/v1/tareas   (requiere area_id de un área tuya)
      def create
        area = current_user.areas.find_by(id: params[:area_id])
        return render_field_error(:area_id, "debe ser un área tuya") unless area

        tarea = area.tareas.create!(tarea_params)
        render json: tarea_json(tarea), status: :created
      end

      # PATCH/PUT /api/v1/tareas/:id
      def update
        @tarea.assign_attributes(tarea_params)
        if params.key?(:area_id)
          area = current_user.areas.find_by(id: params[:area_id])
          return render_field_error(:area_id, "debe ser un área tuya") unless area

          @tarea.area = area
        end
        @tarea.save!
        render json: tarea_json(@tarea)
      end

      # DELETE /api/v1/tareas/:id
      def destroy
        @tarea.destroy!
        head :no_content
      end

      private

      def set_tarea
        @tarea = current_user.tareas.find(params[:id])
      end

      def tarea_params
        params.permit(:titulo, :descripcion, :fecha_limite, :prioridad, :estado, :estimado_minutos)
      end

      def tarea_json(tarea)
        tarea.as_json(only: %i[id titulo descripcion fecha_limite prioridad estado estimado_minutos area_id created_at updated_at])
             .merge("area" => tarea.area.as_json(only: %i[id nombre tipo color]))
      end
    end
  end
end
