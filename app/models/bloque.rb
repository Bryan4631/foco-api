class Bloque < ApplicationRecord
  HORA = /\A([01]\d|2[0-3]):[0-5]\d\z/

  belongs_to :area

  validates :titulo, presence: true, length: { maximum: 120 }
  validates :dia_semana, inclusion: { in: 1..7, message: "debe estar entre 1 (lunes) y 7 (domingo)" }
  validates :hora_inicio, :hora_fin, format: { with: HORA, message: "debe tener formato HH:MM" }
  validate :fin_despues_de_inicio
  validate :sin_solapamiento

  private

  def fin_despues_de_inicio
    return if hora_inicio.blank? || hora_fin.blank?
    errors.add(:hora_fin, "debe ser posterior a la hora de inicio") unless hora_fin > hora_inicio
  end

  def sin_solapamiento
    return if area.blank? || dia_semana.blank? || hora_inicio.blank? || hora_fin.blank?
    return unless hora_fin > hora_inicio

    choque = Bloque.joins(:area)
                   .where(areas: { user_id: area.user_id }, dia_semana: dia_semana)
                   .where.not(id: id)
                   .where("bloques.hora_inicio < ? AND bloques.hora_fin > ?", hora_fin, hora_inicio)
    errors.add(:base, "Se solapa con otro bloque de ese día") if choque.exists?
  end
end
