# frozen_string_literal: true

class PurchaseNotifier
  def self.notify(id, status)
    HTTParty.put("http://testpayments.com/api/purchase/#{id}",
                 headers: { 'Content-Type' => 'application/json' },
                 body: { status: status }.to_json)
  end
end
