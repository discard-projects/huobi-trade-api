# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  store :huobi, accessors: [:access_key, :secret_key, :slack_webhook_url, :trade_enabled], coder: JSON
  after_initialize :initialize_defaults, :if => :new_record?
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  # validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  has_many :accounts
  has_many :balances, through: :accounts
  has_many :balance_intervals, through: :balances
  has_many :order_intervals, through: :balance_intervals
  has_many :balance_smarts, through: :balances
  has_many :order_smarts, through: :balance_smarts

  has_many :orders

  # # 币币交易
  def spot_balances
    self.balances.where('accounts.htype = ?', 'spot')
  end

  def otc_balances
    self.balances.where('accounts.htype = ?', 'otc')
  end

  def huobi_api
    if self.access_key.present? && self.secret_key.present?
      Huobi.new(self.access_key, self.secret_key)
    end
  end

  def is_manager?
    $env[:managers].include? self.email
  end

  def slack_notifier
    if self.slack_webhook_url
      Slack::Notifier.new self.slack_webhook_url do
        defaults channel: "#huobi-notifier",
                 username: "notifier"
      end
    end
  end

  private

  def initialize_defaults
    self.access_key = '' unless(access_key_changed?)
    self.secret_key = '' unless(secret_key_changed?)
    self.slack_webhook_url = '' unless(slack_webhook_url_changed?)
    self.trade_enabled = true unless(trade_enabled_changed?)
  end
end
