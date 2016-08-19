class PageletRails::Encryptor

  DEFAULT_SALT = '!@#Q156^tdSXggT0&*789++8&?_|T%\/++==RqE'

  attr_reader :salt

  def self.encode(data, opts = {})
    self.new(opts).encode data
  end

  def self.decode(encrypted_data, opts = {})
    self.new(opts).decode encrypted_data
  end

  def self.get_key secret, salt
    @get_key_cache ||= {}
    key = [secret, salt]

    @get_key_cache[key] ||= ActiveSupport::KeyGenerator.new(secret).generate_key(salt)
  end

  def initialize(opts = {})
    @salt = opts.fetch :salt, DEFAULT_SALT
    @secret = opts[:secret]
  end

  def secret
    @secret || Rails.application.secrets[:secret_key_base]
  end

  def encode(data)
    encryptor.encrypt_and_sign(data)
  end

  def decode(encrypted_data)
    encryptor.decrypt_and_verify(encrypted_data)
  end

  private

  def encryptor
    @encryptor ||= begin
      key = self.class.get_key secret, salt

      ActiveSupport::MessageEncryptor.new(key)
    end
  end

end
