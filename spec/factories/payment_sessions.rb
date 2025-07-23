# frozen_string_literal: true

FactoryBot.define do
  factory :payment_session do
    ref_trade_id { 'ref1' }
    return_url { 'https://mysite.com/redirect' }
  end
end
