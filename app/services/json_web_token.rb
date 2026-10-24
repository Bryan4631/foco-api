# Crea y valida los tokens JWT de sesión.
# El secreto sale de la variable de entorno JWT_SECRET; si no existe, usa el
# secret_key_base de Rails (que tampoco está escrito en el código).
class JsonWebToken
  ALGORITHM = "HS256".freeze
  EXPIRATION = 24.hours

  class << self
    # Devuelve [token, payload]
    def encode(user)
      payload = {
        sub: user.id.to_s,
        jti: SecureRandom.uuid,
        iat: Time.current.to_i,
        exp: EXPIRATION.from_now.to_i
      }
      [JWT.encode(payload, secret, ALGORITHM), payload]
    end

    # Lanza JWT::ExpiredSignature o JWT::DecodeError si el token no sirve
    def decode(token)
      payload, = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
      payload.with_indifferent_access
    end

    private

    def secret
      ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
    end
  end
end
