require 'spec_helper'

feature "user interacts with social networking features" do
  scenario "user follows and unfollows another user" do
    comedy = Fabricate(:category)
    futurama = Fabricate(:video, category: comedy)
    bob = Fabricate(:user)
    Fabricate(:review, video: futurama, user: bob)

    sign_in

    visit_video_page_from_home_page(futurama)
    expect(page).to have_content futurama.title

    find("a[href='/users/#{bob.id}']").click
    expect(page).to have_content "#{bob.full_name}'s video collections"

    click_link "Follow"
    visit people_path
    expect(page).to have_content bob.full_name

    visit people_path
    find("a[data-method='delete']").click
    expect(page).not_to have_content bob.full_name
  end
end