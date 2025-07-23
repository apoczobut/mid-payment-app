class PaymentSession < ApplicationRecord
  validates :ref_trade_id, presence: true
  validates :return_url, presence: true
end
