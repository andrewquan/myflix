require 'spec_helper'

feature "user resets password" do
  scenario "user successfully resets their password" do
    alice = Fabricate(:user, password: 'old_password')
    visit sign_in_path
    click_link "Forgot Password?"

    fill_in "Email Address", with: alice.email
    click_button "Send Email"

    open_email(alice.email)
    current_email.click_link "Reset Password"

    fill_in "New Password", with: 'new_password'
    click_button "Reset Password"
    expect(page).to have_content "Your password has been updated."

    visit sign_in_path
    fill_in "Email Address", with: alice.email
    fill_in "Password", with: 'new_password'
    click_button "Sign In"
    expect(page).to have_content "You've logged in!"

    clear_email
  end
end