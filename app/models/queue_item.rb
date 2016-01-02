class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_numericality_of :position, only_integer: true

  delegate :title, to: :video, prefix: :video

  def rating
    review = Review.find_by(user_id: user.id, video_id: video.id)
    review.rating if review
  end

  def rating=(new_rating)
    review = Review.find_by(user_id: user.id, video_id: video.id)

    if review
      review.update_column(:rating, new_rating)
    else
      review = Review.create(user: user, video: video, rating: new_rating)
      review.save(validate: false)
    end
  end

  def category_name
    video.category.name
  end
end