require 'spec_helper'

feature "User invites a user to join MyFlix" do
  scenario "User successfully invites a friend and the invitation is accepted", { js: true, vcr: true } do
    alice = Fabricate(:user)
    sign_in(alice)

    invite_a_friend
    sign_out

    friend_accepts_invitation
    friend_signs_in

    friend_follows_inviter_through_invitation(alice)
    sign_out

    sign_in(alice)
    inviter_follows_friend_through_invitation

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in "Friend's Name", with: "James Smith"
    fill_in "Friend's Email Address", with: "james@example.com"
    fill_in "Invitation Message", with: "Join MyFlix!"
    click_button "Send Invitation"
  end

  def friend_accepts_invitation
    open_email "james@example.com"
    current_email.click_link "Join MyFlix"

    fill_in "Password", with: 'password'
    fill_in "Full Name", with: "James Smith"
    fill_in "Credit Card Number", with: '4242424242424242'
    fill_in "Security Code", with: '123'
    select "12 - December", from: "date_month"
    select "2020", from: "date_year"
    click_button "Sign Up"
    expect(page).to have_content "You're now registered!"
  end

  def friend_signs_in
    visit sign_in_path
    fill_in "Email Address", with: "james@example.com"
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  def friend_follows_inviter_through_invitation(inviter)
    click_link "People"
    expect(page).to have_content inviter.full_name
  end

  def inviter_follows_friend_through_invitation
    click_link "People"
    expect(page).to have_content "James Smith"
  end
end