class User < ActiveRecord::Base
  has_many :reviews
  has_many :queue_items, -> { order("position") }
  has_many :following_relationships, class_name: "Relationship", foreign_key: :follower_id
  has_many :leading_relationships, class_name: "Relationship", foreign_key: :leader_id

  has_secure_password validations: false

  validates_presence_of :email, :password, :full_name
  validates_uniqueness_of :email

  def normalize_queue_item_positions
    queue_items.each_with_index do |queue_item, index|
      queue_item.update_attributes(position: index+1)
    end
  end

  def include_video_in_queue?(video)
    queue_items.map(&:video).include?(video)
  end

  def follows?(another_user)
    following_relationships.map(&:leader).include?(another_user)
  end

  def can_follow?(another_user)
    self.follows?(another_user) || another_user == self
  end

  def generate_token
    self.update_column(:token, SecureRandom.urlsafe_base64)
  end

  def follow(another_user)
    following_relationships.create(leader: another_user) unless can_follow?(another_user)
  end
end