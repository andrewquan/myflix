require 'spec_helper'

describe Category do
  it { should have_many(:videos).order("title") }
  it { should validate_presence_of(:name) }

  describe "#recent_videos" do
    it "returns videos in reverse chronological order by created_at" do
      comedy = Category.create(name: "Comedy")
      futurama = Video.create(title: "Futurama", description: "Space travel.", category: comedy, created_at: 1.day.ago)
      family_guy = Video.create(title: "Family Guy", description: "Funny cartoon.", category: comedy)
      expect(comedy.recent_videos).to eq([family_guy, futurama])
    end

    it "returns all videos if there are 6 or less videos" do
      comedy = Category.create(name: "Comedy")
      futurama = Video.create(title: "Futurama", description: "Space travel.", category: comedy)
      family_guy = Video.create(title: "Family Guy", description: "Funny cartoon.", category: comedy)
      expect(comedy.recent_videos.count).to eq(2)
    end

    it "returns a maximum of 6 videos" do
      category = Category.create(name: "Comedy")
      7.times { Video.create(title: "Futurama", description: "Space Travel.", category: category)}
      expect(category.recent_videos.count).to eq(6)
    end

    it "returns the most recent 6 videos" do
      category = Category.create(name: "Comedy")
      6.times { Video.create(title: "Futurama", description: "Space Travel.", category: category)}
      old_video = Video.create(title: "Old", description: "An old video", category: category, created_at: 1.day.ago)
      expect(category.recent_videos).not_to include(old_video)
    end

    it "returns an empty array if the category does not have any videos" do
      category = Category.create(name: "Comedy")
      expect(category.recent_videos).to eq([])
    end
  end
end