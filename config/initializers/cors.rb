# Solo el frontend autorizado puede llamar a la API desde el navegador.
# En producción define CORS_ORIGINS con la URL del frontend (varias separadas por coma).
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "https://foco-web-gamma.vercel.app").split(",").map(&:strip)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      max_age: 600
  end
end
