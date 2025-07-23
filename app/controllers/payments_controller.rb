# frozen_string_literal: true

class PaymentsController < ApplicationController
  def create
    return render_invalid_url unless valid_return_url?

    result = PartnerClient.request_token(purchase_params)

    if result[:success]
      create_payment_session
      render json: { accessToken: result[:accessToken], od_id: result[:od_id] }, status: :ok
    else
      render json: { error: result[:error] }, status: :bad_request
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def return
    # Prevent security vulnerability by fetching stored return_url
    session = PaymentSession.find_by(ref_trade_id: params[:ref_trade_id])
    return render plain: 'Invalid session', status: :unprocessable_entity unless session

    PurchaseNotifier.notify(params[:od_id], purchase_status)

    return render plain: 'Unsafe return URL', status: :forbidden unless ReturnUrlValidator.valid?(session.return_url)

    redirect_to session.return_url, allow_other_host: true
  end

  private

  def purchase_params
    params.permit(:ref_trade_id, :ref_user_id, :od_currency, :od_price, :return_url)
  end

  def purchase_status
    params[:od_status] == '10' ? 'paid' : 'failed'
  end

  def valid_return_url?
    ReturnUrlValidator.valid?(purchase_params[:return_url])
  end

  def render_invalid_url
    render json: { error: 'Invalid return_url' }, status: :bad_request
  end

  def create_payment_session
    PaymentSession.create!(
      ref_trade_id: purchase_params[:ref_trade_id],
      return_url: purchase_params[:return_url]
    )
  end
end
