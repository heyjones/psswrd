class Password < ActiveRecord::Base

  obfuscate_id spin: 9494131049

  before_create :encrypt

  protected

  def encrypt

    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
    self.password = crypt.encrypt_and_sign(self.password)

  end

end
