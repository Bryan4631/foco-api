# Tokens JWT que el usuario cerró con logout. Se guardan por su identificador (jti)
# hasta que expiran, para que dejen de servir aunque aún no hayan vencido.
class RevokedToken < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def self.revoked?(jti)
    exists?(jti: jti)
  end

  def self.revoke!(payload)
    create!(jti: payload[:jti], expires_at: Time.zone.at(payload[:exp]))
  end

  def self.purge_expired
    where("expires_at < ?", Time.current).delete_all
  end
end
