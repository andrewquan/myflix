require 'spec_helper'

describe RelationshipsController do
  describe "GET index" do
    it "sets @relationships for current user's following relationships" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob )
      get :index
      expect(assigns(:relationships)).to eq([relationship])
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :index }
    end
  end

  describe "POST create" do
    it "creates a following relationship for the current user" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      request.env["HTTP_REFERER"] = user_path(bob)
      post :create, leader_id: bob.id
      expect(alice.following_relationships.first.leader).to eq(bob)
    end

    it "redirects to the leader's page" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      request.env["HTTP_REFERER"] = user_path(bob)
      post :create, leader_id: bob.id
      expect(response).to redirect_to user_path(bob)
    end

    it "does not create a relationship if the current user already follows the leader" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      request.env["HTTP_REFERER"] = user_path(bob)
      Fabricate(:relationship, leader: bob, follower: alice)
      post :create, leader_id: bob.id
      expect(Relationship.count).to eq(1)
    end

    it "does not allow one to follow oneself" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      request.env["HTTP_REFERER"] = user_path(bob)
      post :create, leader_id: alice.id
      expect(Relationship.count).to eq(0)
    end
  end

  describe "DELETE destroy" do
    it "deletes the relationship if the current user is the follower" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(0)
    end

    it "redirects to people page" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob)
      delete :destroy, id: relationship.id
      expect(response).to redirect_to people_path
    end

    it "does not delete the relationship if the current user is not the follower" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      nick = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: nick, leader: bob)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(1)
    end

    it_behaves_like "requires sign in" do
      let(:action) { delete :destroy, id: Fabricate(:relationship).id }
    end
  end
end