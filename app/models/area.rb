class Area < ApplicationRecord
  # Asociaciones
  belongs_to :user
  has_many :tareas, dependent: :restrict_with_error
  has_many :bloques, dependent: :restrict_with_error

  # Validaciones
  validates :nombre, presence: true, uniqueness: { scope: :user_id, message: "ya existe en tus áreas" }
  
  # Validamos que el tipo sea uno de los permitidos en tus seeds
  validates :tipo, presence: true, inclusion: { 
    in: %w[estudio emprendimiento trabajo personal], 
    message: "no es un tipo válido" 
  }
end