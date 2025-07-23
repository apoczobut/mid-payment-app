# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payments', type: :request do
  describe 'POST /api/purchase' do
    let(:request) { post api_purchase_path, params: request_params }
    let(:response_body) { { resultCode: '100', accessToken: 'token123', od_id: 'order123' } }

    let(:request_params) do
      {
        ref_trade_id: 'abc123',
        ref_user_id: 'user@example.com',
        od_currency: 'KRW',
        od_price: '1000',
        return_url: 'https://mysite.com/return'
      }
    end

    before do
      stub_request(:post, 'https://partner.com/paygate/auth/').to_return(
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      request
    end

    context 'when success' do
      it 'returns accessToken on success' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['accessToken']).to eq('token123')
      end
    end

    context 'when response error' do
      let(:response_body) { { resultCode: '400', Error: 'Invalid data' } }

      it 'returns error on failure' do
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Invalid data')
      end
    end

    context 'when invalid ActiveRecord input' do
      let(:request_params) do
        {
          ref_trade_id: '',
          ref_user_id: 'user@example.com',
          od_currency: 'KRW',
          od_price: '1000',
          return_url: 'https://mysite.com/return'
        }
      end

      it 'returns error for invalid ActiveRecord input' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when invalid return_url' do
      let(:request_params) do
        {
          ref_trade_id: 'abc1234',
          ref_user_id: 'user@example.com',
          od_currency: 'KRW',
          od_price: '1000',
          return_url: 'https://malicious.com/redirect'
        }
      end

      it 'returns error for invalid return_url' do
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Invalid return_url')
      end
    end
  end

  describe 'POST /customer/returns' do
    let(:payment_session) do
      create :payment_session
    end
    let(:od_id) { 'order123' }
    let(:request) do
      post '/customer/returns', params: {
        ref_trade_id: 'ref1',
        od_id: od_id,
        od_status: od_status
      }
    end
    let(:purchase_notifier) { PurchaseNotifier }
    let(:return_url) { 'https://mysite.com/redirect' }

    before do
      stub_request(:put, 'http://testpayments.com/api/purchase/order123').to_return(status: 200)
      allow(purchase_notifier).to receive(:notify).and_call_original
    end

    context 'when success' do
      let(:od_status) { '10' }

      before do
        payment_session
        request
      end

      it 'notifies success and redirects to return_url' do
        expect(purchase_notifier).to have_received(:notify).with(od_id, 'paid')
        expect(response).to redirect_to(return_url)
      end
    end

    context 'when failure' do
      let(:od_status) { '20' }

      before do
        payment_session
        request
      end

      it 'notifies failure and redirects' do
        expect(purchase_notifier).to have_received(:notify).with(od_id, 'failed')
        expect(response).to redirect_to(return_url)
      end
    end

    context 'when missing session' do
      let(:od_status) { '10' }

      before do
        request
      end

      it 'returns error for missing session' do
        expect(purchase_notifier).not_to have_received(:notify)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
