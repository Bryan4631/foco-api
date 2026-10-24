class Area < ApplicationRecord
  TIPOS = %w[estudio emprendimiento trabajo personal].freeze

  belongs_to :user
  has_many :tareas, dependent: :restrict_with_error
  has_many :bloques, dependent: :restrict_with_error

  validates :nombre, presence: true, length: { maximum: 60 },
                     uniqueness: { scope: :user_id, case_sensitive: false }
  validates :tipo, inclusion: { in: TIPOS }
  validates :color, format: { with: /\A#\h{6}\z/, message: "debe ser un color hexadecimal, por ejemplo #2563eb" }
end
