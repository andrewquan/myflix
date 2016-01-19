require 'spec_helper'

feature "User invites a user to join MyFlix" do
  scenario "User successfully invites a friend and the invitation is accepted" do
    alice = Fabricate(:user)
    sign_in(alice)

    invite_a_friend
    sign_out

    friend_accepts_invitation
    friend_registers_with_invitation

    friend_follows_user_through_invitation
    sign_out

    sign_in(alice)
    inviter_follows_friend_through_invitation

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in "Friend's Name", with: "John Smith"
    fill_in "Friend's Email Address", with: "john@example.com"
    fill_in "Invitation Message", with: "Join MyFlix!"
    click_button "Send Invitation"
  end

  def friend_accepts_invitation
    open_email "john@example.com"
    current_email.click_link "Join MyFlix"

    fill_in "Password", with: 'password'
    fill_in "Full Name", with: "John Smith"
    click_button "Sign Up"
  end

  def friend_registers_with_invitation
    fill_in "Email Address", with: "john@example.com"
    fill_in "Password", with: "password"
    click_button "Sign In"
  end

  def friend_follows_inviter_through_invitation
    click_link "People"
    expect(page).to have_content alice.full_name
  end

  def inviter_follows_friend_through_invitation
    click_link "People"
    expect(page).to have_content "John Smith"
  end
end