class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Recurso no encontrado" }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render_validation_errors(e.record)
  end

  rescue_from ActiveRecord::RecordNotUnique do
    render json: { error: "Ya existe un registro con esos datos" }, status: :conflict
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: "Falta el parámetro: #{e.param}" }, status: :bad_request
  end

  private

  attr_reader :current_user, :current_token_payload

  # Protege los endpoints: exige "Authorization: Bearer <token>" válido, vigente y no revocado.
  def authenticate_user!
    token = request.headers["Authorization"].to_s.split(" ").last
    payload = JsonWebToken.decode(token)
    raise JWT::DecodeError, "Token revocado" if RevokedToken.revoked?(payload[:jti])

    @current_token_payload = payload
    @current_user = User.find(payload[:sub])
  rescue JWT::ExpiredSignature
    render_unauthorized("La sesión expiró, inicia sesión nuevamente")
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render_unauthorized("No autorizado")
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end

  def render_validation_errors(record)
    render json: { error: "Datos inválidos", errors: record.errors.to_hash }, status: 422
  end
end
