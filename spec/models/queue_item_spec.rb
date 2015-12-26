require 'spec_helper'

describe QueueItem do
  describe "#video_title" do
    it "returns the title of the associated video" do
      futurama = Fabricate(:video, title: "Futurama")
      queue_item = Fabricate(:queue_item, video: futurama)
      expect(queue_item.video_title).to eq("Futurama")
    end
  end

  describe "#rating" do
    it "returns the current user's rating for the video when the review is present" do
      alice = Fabricate(:user)
      futurama = Fabricate(:video)
      review = Fabricate(:review, user: alice, video: futurama, rating: 4)
      queue_item = Fabricate(:queue_item, user: alice, video: futurama)
      expect(queue_item.rating).to eq(4)
    end

    it "returns nil if the current user has not left a review for the video" do
      alice = Fabricate(:user)
      futurama = Fabricate(:video)
      queue_item = Fabricate(:queue_item, user: alice, video: futurama)
      expect(queue_item.rating).to be_nil
    end
  end

  describe "#category_name" do
    it "returns the name of the associated video's category" do
      comedy = Fabricate(:category, name: "Comedy")
      futurama = Fabricate(:video, category: comedy)
      queue_item = Fabricate(:queue_item, video: futurama)
      expect(queue_item.category_name).to eq("Comedy")
    end
  end
end