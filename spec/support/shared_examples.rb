shared_examples "requires sign in" do
  it "redirects to sign in page" do
    session[:user_id] = nil
    action
    expect(response).to redirect_to sign_in_path
  end
end

shared_examples "tokenable" do
  it "generates a random token upon create" do
    expect(object.token).to be_present
  end
end