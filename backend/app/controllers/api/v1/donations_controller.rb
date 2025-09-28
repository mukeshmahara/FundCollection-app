module Api
  module V1
    class DonationsController < BaseController
      before_action :authenticate_user!
      before_action :set_donation, only: [:show]

      def index
        donations = current_user.donations.includes(:campaign).recent
        
        # Apply filters
        donations = donations.where(status: params[:status]) if params[:status]
        donations = donations.joins(:campaign).where(campaigns: { id: params[:campaign_id] }) if params[:campaign_id]

        result = paginate_collection(donations, DonationSerializer)
        render_success(result)
      end

      def show
        render_success(DonationSerializer.new(@donation, include: [:campaign]).serializable_hash[:data])
      end

      def create
        campaign = Campaign.find(params[:campaign_id])
        
        unless campaign.can_receive_donations?
          return render_error(['Campaign cannot receive donations'], :bad_request)
        end

        donation = campaign.donations.build(donation_params)
        donation.user = current_user

        if donation.save
          render_success(
            DonationSerializer.new(donation).serializable_hash[:data],
            'Donation created successfully',
            :created
          )
        else
          render_error(donation.errors.full_messages)
        end
      end

      private

      def set_donation
        @donation = current_user.donations.find(params[:id])
      end

      def donation_params
        params.require(:donation).permit(:amount, :anonymous)
      end
    end
  end
end
