class Tarea < ApplicationRecord
  PRIORIDADES = %w[baja media alta].freeze
  ESTADOS = %w[pendiente en_curso hecha].freeze

  belongs_to :area

  validates :titulo, presence: true, length: { maximum: 120 }
  validates :prioridad, inclusion: { in: PRIORIDADES }
  validates :estado, inclusion: { in: ESTADOS }
  validates :estimado_minutos, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 1440 },
                               allow_nil: true

  scope :vencidas, -> { where.not(estado: "hecha").where("fecha_limite < ?", Date.current) }
end
