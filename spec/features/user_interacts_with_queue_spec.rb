require 'spec_helper'

feature "User interacts with the queue" do
  scenario "user adds and reorders videos in the queue" do
    comedy = Fabricate(:category, name: "Comedy")
    futurama = Fabricate(:video, title: "Futurama", category: comedy)
    south_park = Fabricate(:video, title: "South Park", category: comedy)
    family_guy = Fabricate(:video, title: "Family Guy", category: comedy)

    sign_in
    add_video_to_queue(futurama)
    expect_queue_to_have_video(futurama)

    visit video_path(futurama)
    expect_link_not_to_be_seen("+ My Queue")

    add_video_to_queue(south_park)
    add_video_to_queue(family_guy)

    set_queue_position(futurama, 3)
    set_queue_position(south_park, 1)
    set_queue_position(family_guy, 2)
    update_queue

    expect_video_position(south_park, 1)
    expect_video_position(family_guy, 2)
    expect_video_position(futurama, 3)
  end

  def add_video_to_queue(video)
    visit home_path
    find("a[href='/videos/#{video.id}']").click
    click_link "+ My Queue"
  end

  def expect_queue_to_have_video(video)
    expect(page).to have_content video.title
  end

  def expect_link_not_to_be_seen(link_text)
    expect(page).not_to have_content link_text
  end

  def set_queue_position(video, position)
    find("input[data-video-id='#{video.id}']").set(position)
  end

  def update_queue
    click_button "Update Instant Queue"
  end

  def expect_video_position(video, position)
    expect(find("input[data-video-id='#{video.id}']").value).to eq(position.to_s)
  end
end