class Admin::VideosController < ApplicationController
  before_action :require_user
  before_action :require_admin

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      flash[:success] = "You successfully added '#{@video.title}."
      redirect_to new_admin_video_path
    else
      flash.now[:danger] = "The video was not added. Make sure all information is entered correctly."
      render :new
    end
  end

  private

  def require_admin
    if !current_user.admin?
      flash[:danger] = "You do not have permission to do that."
      redirect_to home_path
    end
  end

  def video_params
    params.require(:video).permit(
      :title,
      :description,
      :category_id,
      :large_cover,
      :small_cover,
      :video_url
    )
  end
end