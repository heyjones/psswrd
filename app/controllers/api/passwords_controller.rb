class Api::PasswordsController < Api::BaseController

  before_action :set_password, only: [:show]

  def show
    puts request.referrer
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
    @password = Password.new(password: slack_params[:text])
    if @password.save
      HTTParty.post(
        'https://slack.com/api/chat.postMessage',
        headers:{
          'Content-Type' => 'application/json'
        },
        body: {
          token: Rails.application.secrets.slack_api_token,
          channel: slack_params[:channel],
          text: polymorphic_url(@password),
          unfurl_links: false
        }
      )
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
