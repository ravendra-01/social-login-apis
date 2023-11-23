class JsonWebToken
  attr_reader :id, :expiration, :type, :user_id
  def self.encode(id, data = {}, expiration = nil)
    expiration, data = data, expiration unless data.is_a?(Hash)
    data       ||= {}
    expiration ||= 24.hours.from_now
    payload = build_payload_for(id.to_i, data, expiration.to_i)
    JWT.encode payload, secret_key, algorithm
  end

  def self.decode(token)
    JsonWebToken.new token_data_for(token)
  end

  def initialize(data)
    @id = data.delete('id')
    @expiration = Time.at(data.delete('exp')).to_time
    @user_id = data.delete('user_id')
    @type = data.delete('type')
  end

  private

  def self.token_data_for(token)
    JWT.decode(token, secret_key, true, {
      :algorithm => algorithm,
    })[0]
  end

  def self.build_payload_for(id, data, expiration)
    {
      :id  => id,
      :exp => expiration,
    }.merge(data)
  end

  def self.secret_key
    @secret_key ||= Rails.application.secret_key_base
  end

  def self.algorithm
    'HS512'
  end
end

  