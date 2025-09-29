class Api::V1::TokensController < ApplicationController
  def refresh
    refresh_token = RefreshToken.find_by(token: params[:refresh_token])

    if refresh_token && !refresh_token.expired?
      access_token = Warden::JWTAuth::UserEncoder.new.call(refresh_token.user, :user, nil).first
      render json: { access_token: access_token }
    else
      render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
    end
  end
end
