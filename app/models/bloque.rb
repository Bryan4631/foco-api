class Bloque < ApplicationRecord
  belongs_to :area

  # Validaciones básicas
  validates :titulo, presence: true
  validates :dia_semana, presence: true, inclusion: { in: 1..7, message: "debe ser un día válido (1=Lunes, 7=Domingo)" }
  
  # Validación personalizada (Regla de negocio)
  validate :hora_fin_posterior_a_inicio

  private

  def hora_fin_posterior_a_inicio
    # Si falta alguna hora, no validamos aquí (la validación de presence se encarga de eso)
    return if hora_inicio.blank? || hora_fin.blank?

    # Comparamos las horas
    if hora_inicio >= hora_fin
      errors.add(:hora_fin, "debe ser posterior a la hora de inicio")
    end
  end
end