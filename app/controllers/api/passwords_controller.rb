class Api::PasswordsController < Api::BaseController

  before_action :set_password, only: [:show]

  def show
    if @password.ip? && @password.ip != request.remote_ip.to_s
      render text: ''
    else
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
      @password.password = crypt.decrypt_and_verify(@password.password)
      render text: @password.password
      @password.destroy
    end
  end

  def create
    @password = Password.new(password: password_params[:text])
    if @password.save
      render text: polymorphic_url(@password)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_password
    @password = Password.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render text: ''
  end

  # Only allow a trusted parameter "white list" through.
  def password_params
    params.permit(:text, :ip)
  end

end
