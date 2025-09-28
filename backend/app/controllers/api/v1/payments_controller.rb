module Api
  module V1
    class PaymentsController < BaseController
      before_action :authenticate_user!

      def create_payment_intent
        donation = Donation.find(params[:donation_id])
        
        unless donation.user == current_user
          return render_error(['Unauthorized'], :forbidden)
        end

        unless donation.pending?
          return render_error(['Donation is not in pending status'], :bad_request)
        end

        begin
          # Create Stripe Payment Intent
          payment_intent = Stripe::PaymentIntent.create({
            amount: (donation.amount * 100).to_i, # Convert to cents
            currency: 'usd',
            metadata: {
              donation_id: donation.id,
              campaign_id: donation.campaign_id,
              user_id: current_user.id
            }
          })

          # Create transaction record
          transaction = donation.build_transaction(
            stripe_payment_intent_id: payment_intent.id,
            amount: donation.amount,
            status: payment_intent.status
          )

          if transaction.save
            render_success({
              client_secret: payment_intent.client_secret,
              payment_intent_id: payment_intent.id,
              transaction_id: transaction.id
            })
          else
            render_error(transaction.errors.full_messages)
          end
        rescue Stripe::StripeError => e
          render_error(["Payment processing error: #{e.message}"])
        end
      end

      def confirm
        transaction = Transaction.find(params[:transaction_id])
        donation = transaction.donation

        unless donation.user == current_user
          return render_error(['Unauthorized'], :forbidden)
        end

        begin
          # Retrieve the payment intent from Stripe
          payment_intent = Stripe::PaymentIntent.retrieve(transaction.stripe_payment_intent_id)
          
          # Update transaction status
          transaction.update!(status: payment_intent.status)
          
          # Update donation status based on payment intent status
          case payment_intent.status
          when 'succeeded'
            donation.update!(status: :successful)
            render_success({
              donation: DonationSerializer.new(donation).serializable_hash[:data],
              transaction: TransactionSerializer.new(transaction).serializable_hash[:data]
            }, 'Payment confirmed successfully')
          when 'canceled'
            donation.update!(status: :failed)
            render_error(['Payment was canceled'])
          else
            render_success({
              donation: DonationSerializer.new(donation).serializable_hash[:data],
              transaction: TransactionSerializer.new(transaction).serializable_hash[:data]
            }, 'Payment status updated')
          end
        rescue Stripe::StripeError => e
          render_error(["Payment confirmation error: #{e.message}"])
        end
      end
    end
  end
end
