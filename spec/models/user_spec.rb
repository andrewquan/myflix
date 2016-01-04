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
end