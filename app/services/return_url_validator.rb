# frozen_string_literal: true

class ReturnUrlValidator
  ALLOWED_DOMAINS = ['mysite.com'].freeze

  private_constant :ALLOWED_DOMAINS

  def self.valid?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTPS) && uri.host.present? && ALLOWED_DOMAINS.any? { |d| uri.host.end_with?(d) }
  rescue URI::InvalidURIError
    false
  end
end
