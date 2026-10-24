module Api
  module V1
    class BloquesController < BaseController
      before_action :set_bloque, only: %i[show update destroy]

      # GET /api/v1/bloques?dia_semana=1&area_id=2
      def index
        bloques = current_user.bloques.includes(:area)
        bloques = bloques.where(dia_semana: params[:dia_semana]) if params[:dia_semana].present?
        bloques = bloques.where(area_id: params[:area_id]) if params[:area_id].present?
        render json: bloques.order(:dia_semana, :hora_inicio).map { |b| bloque_json(b) }
      end

      # GET /api/v1/bloques/:id
      def show
        render json: bloque_json(@bloque)
      end

      # POST /api/v1/bloques   (requiere area_id de un área tuya)
      def create
        area = current_user.areas.find_by(id: params[:area_id])
        return render_field_error(:area_id, "debe ser un área tuya") unless area

        bloque = area.bloques.create!(bloque_params)
        render json: bloque_json(bloque), status: :created
      end

      # PATCH/PUT /api/v1/bloques/:id
      def update
        @bloque.assign_attributes(bloque_params)
        if params.key?(:area_id)
          area = current_user.areas.find_by(id: params[:area_id])
          return render_field_error(:area_id, "debe ser un área tuya") unless area

          @bloque.area = area
        end
        @bloque.save!
        render json: bloque_json(@bloque)
      end

      # DELETE /api/v1/bloques/:id
      def destroy
        @bloque.destroy!
        head :no_content
      end

      private

      def set_bloque
        @bloque = current_user.bloques.find(params[:id])
      end

      def bloque_params
        params.permit(:titulo, :dia_semana, :hora_inicio, :hora_fin)
      end

      def bloque_json(bloque)
        bloque.as_json(only: %i[id titulo dia_semana hora_inicio hora_fin area_id created_at updated_at])
              .merge("area" => bloque.area.as_json(only: %i[id nombre tipo color]))
      end
    end
  end
end
