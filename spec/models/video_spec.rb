require 'spec_helper'

describe Video do
  it { should belong_to(:category) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }

  describe "search_by_title" do
    it "returns an empty array if there is no match" do
      futurama = Video.create(title: "Futurama", description: "A show about the future.")
      back_to_the_future = Video.create(title: "Back to the Future", description: "Time travel.")
      expect(Video.search_by_title("hello")).to eq([])
    end

    it "returns an array of one video for an exact match" do
      futurama = Video.create(title: "Futurama", description: "A show about the future.")
      back_to_the_future = Video.create(title: "Back to the Future", description: "Time travel.")
      expect(Video.search_by_title("Futurama")).to eq([futurama])
    end

    it "returns an array of one video for a partial match" do
      futurama = Video.create(title: "Futurama", description: "A show about the future.")
      back_to_the_future = Video.create(title: "Back to the Future", description: "Time travel.")
      expect(Video.search_by_title("urama")).to eq([futurama])
    end

    it "returns an array of all matches ordered by created_at" do
      futurama = Video.create(title: "Futurama", description: "A show about the future.", created_at: 1.day.ago)
      back_to_the_future = Video.create(title: "Back to the Future", description: "Time travel.")
      expect(Video.search_by_title("Futur")).to eq([back_to_the_future, futurama])
    end
  end
end