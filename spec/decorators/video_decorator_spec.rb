require 'spec_helper'

describe VideoDecorator do
  it "returns the average rating of all reviews if there are any reviews" do
    futurama = Fabricate(:video).decorate
    review1 = Fabricate(:review, rating: 5, video: futurama)
    review2 = Fabricate(:review, rating: 3, video: futurama)
    review3 = Fabricate(:review, rating: 2, video: futurama)
    expect(futurama.average_rating).to eq("3.3/5")
  end

  it "returns 'N/A' when there aren't any reviews" do
    futurama = Fabricate(:video).decorate
    expect(futurama.average_rating).to eq("N/A")
  end
end