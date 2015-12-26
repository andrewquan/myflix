require 'spec_helper'

describe QueueItemsController do
  describe "GET index" do
    it "sets @queue_items for the queue items of the logged in user" do
      alice = Fabricate(:user)
      session[:user_id] = alice.id
      queue_item1 = Fabricate(:queue_item, user: alice)
      queue_item2 = Fabricate(:queue_item, user: alice)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it "redirects to the sign in page for unauthorized users" do
      get :index
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "POST create" do
    it "redirects to the my queue page" do
      video = Fabricate(:video)
      session[:user_id] = Fabricate(:user).id
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end

    it "creates a queue item" do
      video = Fabricate(:video)
      session[:user_id] = Fabricate(:user).id
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it "creates a queue item associated with the video" do
      video = Fabricate(:video)
      session[:user_id] = Fabricate(:user).id
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it "creates a queue item associated with the logged in user" do
      alice = Fabricate(:user)
      video = Fabricate(:video)
      session[:user_id] = alice.id
      post :create, video_id: video.id
      expect(QueueItem.first.user).to eq(alice)
    end

    it "puts the video as the last item on the queue list" do
      alice = Fabricate(:user)
      video1 = Fabricate(:video)
      video2 = Fabricate(:video)
      session[:user_id] = alice.id
      Fabricate(:queue_item, user: alice, video: video1)
      post :create, video_id: video2.id
      video2_queue_item = QueueItem.find_by(user_id: alice.id, video_id: video2.id)
      expect(video2_queue_item.position).to eq(2)
    end

    it "does not create a queue item if the video is already in the queue" do
      alice = Fabricate(:user)
      video1 = Fabricate(:video)
      session[:user_id] = alice.id
      Fabricate(:queue_item, user: alice, video: video1)
      post :create, video_id: video1.id
      expect(QueueItem.count).to eq(1)
    end

    it "redirects to the sign in page for unauthenticated users" do
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "DELETE destroy" do
    it "redirects to the my queue page" do
      session[:user_id] = Fabricate(:user).id
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to my_queue_path
    end

    it "deletes the queue item" do
      alice = Fabricate(:user)
      session[:user_id] = alice.id
      queue_item = Fabricate(:queue_item, user: alice)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it "does not delete the queue item if it doesn't belong to the current user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      session[:user_id] = alice.id
      queue_item = Fabricate(:queue_item, user: bob)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(1)
    end

    it "redirects to the sign in page for unauthenticated users" do
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to sign_in_path
    end
  end
end