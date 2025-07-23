# frozen_string_literal: true

class PartnerClient
  def self.request_token(data)
    response = HTTParty.post('https://partner.com/paygate/auth/',
                             headers: { 'Content-Type' => 'application/json' },
                             body: data.to_json)

    body = JSON.parse(response.body)
    if body['resultCode'] == '100'
      { success: true, accessToken: body['accessToken'], od_id: body['od_id'] }
    else
      { success: false, error: body['Error'] || 'Unknown error' }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end
end
