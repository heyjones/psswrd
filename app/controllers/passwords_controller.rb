class PasswordsController < ApplicationController

  before_action :set_password, only: [:show]

  # GET /passwords/1
  def show
    if request.user_agent == 'Slackbot-LinkExpanding 1.0 (+https://api.slack.com/robots)'
      head 200, content_type: 'text/html'
    else
      if @password.ip? && @password.ip != request.remote_ip.to_s
        redirect_to :root
      else
        crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
        @password.password = crypt.decrypt_and_verify(@password.password)
        @password.destroy
      end
    end
  end

  # GET /passwords/new
  def new
    @password = Password.new
  end

  # POST /passwords
  def create
    @password = Password.new(password_params)
    if @password.save
      respond_to do |format|
        format.js
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_password
    @password = Password.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to :root
  end

  # Only allow a trusted parameter "white list" through.
  def password_params
    params.require(:password).permit(:password, :ip)
  end

end
