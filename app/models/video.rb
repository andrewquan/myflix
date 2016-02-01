class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> {order("created_at DESC")}
  has_many :queue_items

  validates_presence_of :title, :description

  mount_uploader :large_cover, LargeCoverUploader
  mount_uploader :small_cover, SmallCoverUploader

  def self.search_by_title(search_term)
    where("lower(title) LIKE ?", "%#{search_term}%".downcase).order("created_at DESC")
  end

  def average_rating
    arr = self.reviews.map {|review| review.rating }
    average = arr.inject(0.0) {|sum, n| sum + n} / arr.size
    average.round(1)
  end
end