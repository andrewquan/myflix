require 'spec_helper'

describe Admin::VideosController do
  describe "GET new" do
    it "sets the @video to a new video" do
      set_admin_user
      get :new
      expect(assigns(:video)).to be_instance_of(Video)
      expect(assigns(:video)).to be_new_record
    end

    it "redirects regular users to the home path" do
      set_current_user
      get :new
      expect(response).to redirect_to home_path
    end

    it "sets the flash error for regular users" do
      set_current_user
      get :new
      expect(flash[:error]).to be_present
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :new }
    end
  end
end