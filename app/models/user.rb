class User < ApplicationRecord
  has_secure_password

  has_many :areas, dependent: :destroy
  has_many :tareas, through: :areas
  has_many :bloques, through: :areas

  before_validation { self.email = email.to_s.strip.downcase }

  validates :nombre, presence: true, length: { maximum: 80 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
