class ReviewsController < ApplicationController
  before_action :require_user

  def create
    @video = Video.find(params[:video_id])
    review = @video.reviews.new(review_params.merge!(user: current_user))
    
    if review.save
      redirect_to video_path(@video)
    else
      flash[:error] = "Please include some comments."
      @reviews = @video.reviews.reload
      render 'videos/show'
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end