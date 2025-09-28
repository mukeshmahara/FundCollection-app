module Api
  module V1
    class WebhooksController < BaseController
      skip_before_action :authenticate_user!
      protect_from_forgery with: :null_session

      def stripe
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
        rescue JSON::ParserError => e
          return render json: { error: 'Invalid payload' }, status: 400
        rescue Stripe::SignatureVerificationError => e
          return render json: { error: 'Invalid signature' }, status: 400
        end

        # Handle the event
        case event['type']
        when 'payment_intent.succeeded'
          handle_payment_success(event['data']['object'])
        when 'payment_intent.payment_failed'
          handle_payment_failure(event['data']['object'])
        when 'payment_intent.canceled'
          handle_payment_canceled(event['data']['object'])
        else
          Rails.logger.info "Unhandled event type: #{event['type']}"
        end

        render json: { status: 'success' }
      end

      private

      def handle_payment_success(payment_intent)
        transaction = Transaction.find_by(stripe_payment_intent_id: payment_intent['id'])
        return unless transaction

        ActiveRecord::Base.transaction do
          transaction.update!(status: :succeeded)
          transaction.donation.update!(status: :successful)
          
          Rails.logger.info "Payment succeeded for donation #{transaction.donation.id}"
        end
      rescue => e
        Rails.logger.error "Error handling payment success: #{e.message}"
      end

      def handle_payment_failure(payment_intent)
        transaction = Transaction.find_by(stripe_payment_intent_id: payment_intent['id'])
        return unless transaction

        ActiveRecord::Base.transaction do
          transaction.update!(status: :canceled)
          transaction.donation.update!(status: :failed)
          
          Rails.logger.info "Payment failed for donation #{transaction.donation.id}"
        end
      rescue => e
        Rails.logger.error "Error handling payment failure: #{e.message}"
      end

      def handle_payment_canceled(payment_intent)
        transaction = Transaction.find_by(stripe_payment_intent_id: payment_intent['id'])
        return unless transaction

        ActiveRecord::Base.transaction do
          transaction.update!(status: :canceled)
          transaction.donation.update!(status: :failed)
          
          Rails.logger.info "Payment canceled for donation #{transaction.donation.id}"
        end
      rescue => e
        Rails.logger.error "Error handling payment cancellation: #{e.message}"
      end
    end
  end
end
