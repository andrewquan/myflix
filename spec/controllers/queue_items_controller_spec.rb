require 'spec_helper'

describe QueueItemsController do
  describe "GET index" do
    it "sets @queue_items for the queue items of the logged in user" do
      alice = Fabricate(:user)
      set_current_user(alice)
      queue_item1 = Fabricate(:queue_item, user: alice)
      queue_item2 = Fabricate(:queue_item, user: alice)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :index }
    end
  end

  describe "POST create" do
    it "redirects to the my queue page" do
      video = Fabricate(:video)
      set_current_user
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end

    it "creates a queue item" do
      video = Fabricate(:video)
      set_current_user
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it "creates a queue item associated with the video" do
      video = Fabricate(:video)
      set_current_user
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it "creates a queue item associated with the logged in user" do
      alice = Fabricate(:user)
      video = Fabricate(:video)
      set_current_user(alice)
      post :create, video_id: video.id
      expect(QueueItem.first.user).to eq(alice)
    end

    it "puts the video as the last item on the queue list" do
      alice = Fabricate(:user)
      video1 = Fabricate(:video)
      video2 = Fabricate(:video)
      set_current_user(alice)
      Fabricate(:queue_item, user: alice, video: video1)
      post :create, video_id: video2.id
      video2_queue_item = QueueItem.find_by(user_id: alice.id, video_id: video2.id)
      expect(video2_queue_item.position).to eq(2)
    end

    it "does not create a queue item if the video is already in the queue" do
      alice = Fabricate(:user)
      video1 = Fabricate(:video)
      set_current_user(alice)
      Fabricate(:queue_item, user: alice, video: video1)
      post :create, video_id: video1.id
      expect(QueueItem.count).to eq(1)
    end

    it_behaves_like "requires sign in" do
      let(:action) { post :create, video_id: 3 }
    end
  end

  describe "DELETE destroy" do
    it "redirects to the my queue page" do
      set_current_user
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to my_queue_path
    end

    it "deletes the queue item" do
      alice = Fabricate(:user)
      set_current_user(alice)
      queue_item = Fabricate(:queue_item, user: alice)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it "normalizes the remaining queue items" do
      alice = Fabricate(:user)
      set_current_user(alice)
      queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
      queue_item2 = Fabricate(:queue_item, user: alice, position: 2)
      queue_item3 = Fabricate(:queue_item, user: alice, position: 3)
      delete :destroy, id: queue_item1.id
      expect(alice.queue_items.map(&:position)).to eq([1, 2])
    end

    it "does not delete the queue item if it doesn't belong to the current user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      set_current_user(alice)
      queue_item = Fabricate(:queue_item, user: bob)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(1)
    end

    it_behaves_like "requires sign in" do
      let(:action) { delete :destroy, id: 3 }
    end
  end

  describe "POST update_queue" do
    context "with valid inputs" do

      let(:alice) { Fabricate(:user) }
      let(:video1) { Fabricate(:video) }
      let(:video2) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: alice, position: 1, video: video1) }
      let(:queue_item2) { Fabricate(:queue_item, user: alice, position: 2, video: video2) }

      before { set_current_user(alice) }

      it "redirects to the my queue page" do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(response).to redirect_to my_queue_path
      end

      it "updates the positions of the queue items" do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(alice.queue_items).to eq([queue_item2, queue_item1])
      end

      it "normalizes the positions of the queue items" do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2}]
        expect(alice.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    context "with invalid inputs" do
      
      let(:alice) { Fabricate(:user) }
      let(:video1) { Fabricate(:video) }
      let(:video2) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: alice, position: 1, video: video1) }
      let(:queue_item2) { Fabricate(:queue_item, user: alice, position: 2, video: video2) }

      before { set_current_user(alice) }

      it "redirects to the my queue page" do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3.1}, {id: queue_item2.id, position: 2}]
        expect(response).to redirect_to my_queue_path
      end

      it "gives a flash error" do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3.1}, {id: queue_item2.id, position: 2}]
        expect(flash[:danger]).not_to be_blank
      end

      it "does not change any of the queue item positions even if one is valid" do
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2.4}]
        expect(queue_item1.reload.position).to eq(1)
      end
    end

    context "with queue items that do not belong to current user" do
      it "doesn't update the queue item" do
        alice = Fabricate(:user)
        bob = Fabricate(:user)
        set_current_user(alice)
        video1 = Fabricate(:video)
        video2 = Fabricate(:video)
        queue_item1 = Fabricate(:queue_item, user: bob, position: 1, video: video1)
        queue_item2 = Fabricate(:queue_item, user: bob, position: 2, video: video2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(bob.queue_items).to eq([queue_item1, queue_item2])
      end
    end

    it_behaves_like "requires sign in" do
      let(:action) { post :update_queue, queue_items: [{id: 1, position: 2}, {id: 2, position: 1}] }
    end
  end
end