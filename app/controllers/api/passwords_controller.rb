class Api::PasswordsController < Api::BaseController

  before_action :set_password, only: [:show]

  def show
    if @password.ip? && @password.ip != request.remote_ip.to_s
      render text: ''
    else
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
      password = crypt.decrypt_and_verify(@password.password)
      @password.destroy
      render text: password
    end
  end

  def create
    @password = Password.new(password_params)
    if @password.save
      render text: polymorphic_url(@password)
    end
  end

  def slack
    @password = Password.new(password: slack_params[:text], ip: nil)
    if @password.save
      request = 'https://slack.com/api/chat.postMessage?token=' + Rails.application.secrets.slack_api_token + '&channel=' + slack_params[:channel_id] + '&text=' + polymorphic_url(@password) + '&username=psswrd&icon_url=' + ActionController::Base.helpers.image_url('favicon.png') + '&unfurl_links=false&unfurl_media=false'
      response = HTTParty.get(request)
      if response.code == 200
        head 200, content_type: 'text/html'
      else
        head 500, content_type: 'text/html'
      end
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
    params.permit(:password, :ip)
  end

  def slack_params
    params.permit(:token, :team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name, :command, :text, :response_url)
  end

end
