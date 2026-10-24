module Api
  module V1
    class BloquesController < BaseController
      before_action :set_bloque, only: [:show, :update, :destroy]

      def index
        bloques = Bloque.joins(:area).where(areas: { user_id: current_user.id }).order(dia_semana: :asc)
        render json: bloques, status: :ok
      end

      def create
        area = current_user.areas.find(params[:bloque][:area_id])
        bloque = area.bloques.new(bloque_params.except(:area_id))

        if bloque.save
          render json: bloque, status: :created
        else
          render json: { errors: bloque.errors.messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: { area: ["no válida o no te pertenece"] } }, status: :unprocessable_entity
      end

      def update
        if params[:bloque][:area_id].present?
          current_user.areas.find(params[:bloque][:area_id])
        end
        if @bloque.update(bloque_params)
          render json: @bloque, status: :ok
        else
          render json: { errors: @bloque.errors.messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @bloque.destroy
        head :no_content
      end

      private

      def set_bloque
        @bloque = Bloque.joins(:area).where(areas: { user_id: current_user.id }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Bloque no encontrado' }, status: :not_found
      end

      def bloque_params
        params.require(:bloque).permit(:titulo, :dia_semana, :hora_inicio, :hora_fin, :area_id)
      end
    end
  end
end