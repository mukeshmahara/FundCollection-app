module Api
  module V1
    class CampaignsController < BaseController
      before_action :set_campaign, only: [:show, :donate, :donations]
      before_action :authenticate_user!, only: [:create, :update, :destroy, :donate]

      def index
        campaigns = Campaign.includes(:creator, image_attachment: :blob)
        
        # Apply filters
        campaigns = campaigns.active unless params[:include_inactive]
        campaigns = campaigns.where('title ILIKE ?', "%#{params[:search]}%") if params[:search]
        campaigns = campaigns.where('goal_amount >= ?', params[:min_goal]) if params[:min_goal]
        campaigns = campaigns.where('goal_amount <= ?', params[:max_goal]) if params[:max_goal]
        
        # Apply sorting
        case params[:sort]
        when 'trending'
          campaigns = campaigns.trending
        when 'ending_soon'
          campaigns = campaigns.ending_soon
        when 'recent'
          campaigns = campaigns.recent
        else
          campaigns = campaigns.recent
        end

        result = paginate_collection(campaigns, CampaignSerializer)
        render_success(result)
      end

      def show
        render_success(CampaignSerializer.new(@campaign, include: [:creator]).serializable_hash[:data])
      end

      def create
        campaign = current_user.created_campaigns.build(campaign_params)
        campaign.creator = current_user

        if campaign.save
          render_success(
            CampaignSerializer.new(campaign).serializable_hash[:data],
            'Campaign created successfully',
            :created
          )
        else
          render_error(campaign.errors.full_messages)
        end
      end

      def update
        campaign = current_user.created_campaigns.find(params[:id])
        
        if campaign.update(campaign_params)
          render_success(
            CampaignSerializer.new(campaign).serializable_hash[:data],
            'Campaign updated successfully'
          )
        else
          render_error(campaign.errors.full_messages)
        end
      end

      def destroy
        campaign = current_user.created_campaigns.find(params[:id])
        campaign.destroy
        render_success(nil, 'Campaign deleted successfully')
      end

      def donate
        unless @campaign.can_receive_donations?
          return render_error(['Campaign cannot receive donations'], :bad_request)
        end

        donation = @campaign.donations.build(donation_params)
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

      def donations
        donations = @campaign.donations.includes(:user).successful.recent
        result = paginate_collection(donations, DonationSerializer)
        render_success(result)
      end

      private

      def set_campaign
        @campaign = Campaign.find(params[:id])
      end

      def campaign_params
        params.require(:campaign).permit(:title, :description, :goal_amount, :deadline, :image, :status)
      end

      def donation_params
        params.require(:donation).permit(:amount, :anonymous)
      end
    end
  end
end
