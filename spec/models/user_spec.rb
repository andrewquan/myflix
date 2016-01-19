require 'spec_helper'

describe User do
  it { should have_many(:reviews) }
  it { should have_many(:queue_items).order("position") }
  it { should have_secure_password }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:full_name) }
  it { should validate_uniqueness_of(:email) }

  describe "#include_video_in_queue?" do
    it "returns true if video is included in the user's queue" do
      alice = Fabricate(:user)
      video = Fabricate(:video)
      queue_item = Fabricate(:queue_item, user: alice, video: video)
      expect(alice.include_video_in_queue?(video)).to be_true
    end

    it "returns false if video is not included in the user's queue" do
      alice = Fabricate(:user)
      video = Fabricate(:video)
      expect(alice.include_video_in_queue?(video)).to be_false
    end
  end

  describe "#follows?" do
    it "returns true if the user is following another user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader: bob, follower: alice)
      expect(alice.follows?(bob)).to be true
    end

    it "returns false if the user is not following another user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader: alice, follower: bob)
      expect(alice.follows?(bob)).to be false
    end
  end

  describe "#generate_token" do
    it "generates a random token for the user" do
      alice = Fabricate(:user)
      expect(alice.generate_token).not_to be_blank
    end
  end

  describe "#follow" do
    it "follows another user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      alice.follow(bob)
      expect(alice.follows?(bob)).to be true
    end

    it "does not follow oneself" do
      alice = Fabricate(:user)
      alice.follow(alice)
      expect(alice.follows?(alice)).to be false
    end
  end
end