def set_current_user(user=nil)
  session[:user_id] = (user || Fabricate(:user)).id
end

def set_current_admin(admin=nil)
  session[:user_id] = (admin || Fabricate(:admin)).id
end

def sign_in(user=nil)
  user ||= Fabricate(:user)
  visit sign_in_path
  fill_in "Email Address", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign In"
end

def admin_sign_in(admin_user=nil)
  admin ||= Fabricate(:admin)
  visit sign_in_path
  fill_in "Email Address", with: admin.email
  fill_in "Password", with: admin.password
  click_button "Sign In"
end

def sign_out
  visit sign_out_path
end

def visit_video_page_from_home_page(video)
  visit home_path
  find("a[href='/videos/#{video.id}']").click
end