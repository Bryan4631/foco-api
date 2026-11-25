ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # --- Ayudantes para los tests de la API ---

    def crear_usuario(nombre: "Usuario", email: "usuario#{SecureRandom.hex(3)}@foco.cl", rol: "usuario")
      User.create!(nombre: nombre, email: email, password: "clave12345", rol: rol)
    end

    # Cabecera "Authorization: Bearer <jwt>" para un usuario
    def auth_headers(user)
      token, = JsonWebToken.encode(user)
      { "Authorization" => "Bearer #{token}" }
    end

    def crear_area(user, nombre: "Area #{SecureRandom.hex(3)}")
      user.areas.create!(nombre: nombre, tipo: "estudio")
    end
  end
end
