class VideoDecorator < Draper::Decorator
  delegate_all

  def average_rating
    object.reviews.average(:rating) ? "#{object.reviews.average(:rating).round(1)}/5" : "N/A"
  end
end