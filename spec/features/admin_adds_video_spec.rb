require 'spec_helper'

feature "admin user adds a video" do
  scenario "admin user adds a video", :vcr do
    comedy = Fabricate(:category, name: "Comedy")

    admin_sign_in
    
    visit new_admin_video_path
    fill_in "Title", with: "Futurama"
    select "Comedy", from: "Category"
    fill_in "Description", with: "Space travel."
    attach_file "Large Cover", 'spec/support/uploads/futurama_large.jpg'
    attach_file "Small Cover", 'spec/support/uploads/futurama.jpg'
    fill_in "Video URL", with: "http://example.com/my_video.mp4"
    click_button "Add Video"

    sign_out
    
    sign_in
    visit video_path(Video.first)
    expect(page).to have_selector("img[src^='https://andrewquan-myflix-app-development.s3.amazonaws.com/uploads/futurama_large.jpg']")
    expect(page).to have_selector("a[href='http://example.com/my_video.mp4']")
  end
end