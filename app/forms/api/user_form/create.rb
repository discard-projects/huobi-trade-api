module Api::UserForm
  class Create < ReformBase
    model :user

    property :email
    property :password
    property :confirmed_at
    property :access_key
    property :secret_key
    property :slack_webhook_url

    validates :email, :password, :access_key, :secret_key, :slack_webhook_url, presence: true, length: { maximum: 255 }
  end
end