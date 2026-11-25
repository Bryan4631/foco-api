module Api
  module V1
    class BloquesController < BaseController
      before_action :set_bloque, only: [ :show, :update, :destroy ]

      # GET /api/v1/bloques
      def index
        bloques = ver_todos? ? Bloque.all : Bloque.joins(:area).where(areas: { user_id: current_user.id })
        render json: bloques.order(dia_semana: :asc), status: :ok
      end

      # GET /api/v1/bloques/:id
      # Antes faltaba esta acción: la ruta existía (resources) pero el controller no la definía.
      def show
        authorize!(@bloque, :show)
        render json: @bloque, status: :ok
      end

      # POST /api/v1/bloques
      def create
        area = area_propia!(params[:bloque][:area_id])
        bloque = area.bloques.new(bloque_params.except(:area_id))

        if bloque.save
          render json: bloque, status: :created
        else
          render json: { errors: bloque.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: { area: [ "no válida o no te pertenece" ] } }, status: :unprocessable_entity
      end

      # PATCH/PUT /api/v1/bloques/:id
      def update
        authorize!(@bloque, :update)
        area_propia!(params[:bloque][:area_id]) if params[:bloque][:area_id].present?

        if @bloque.update(bloque_params)
          render json: @bloque, status: :ok
        else
          render json: { errors: @bloque.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        # Un area_id ajeno ahora responde 422, igual que en tareas#update.
        render json: { errors: { area: [ "no válida o no te pertenece" ] } }, status: :unprocessable_entity
      end

      # DELETE /api/v1/bloques/:id
      def destroy
        authorize!(@bloque, :destroy)
        @bloque.destroy
        head :no_content
      end

      private

      def set_bloque
        @bloque = Bloque.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Bloque no encontrado" }, status: :not_found
      end

      def bloque_params
        params.require(:bloque).permit(:titulo, :dia_semana, :hora_inicio, :hora_fin, :area_id)
      end
    end
  end
end
