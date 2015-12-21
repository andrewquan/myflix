# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

comedy = Category.create(name: "Comedy")
drama = Category.create(name: "Drama")

Video.create(title: "Family Guy", description: "A funny animated show about a dysfunctional family.", small_cover_url: '/tmp/family_guy.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "Futurama", description: "Pizza boy Philip J. Fry awakens in the 31st century after 1,000 years of cryogenic preservation in this animated series. After he gets a job at an interplanetary delivery service, Fry embarks on ridiculous escapades to make sense of his predicament.", small_cover_url: '/tmp/futurama.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "South Park", description: "A funny animated show about a four friends.", small_cover_url: '/tmp/south_park.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "Monk", description: "I have no idea what this show is about.", small_cover_url: '/tmp/monk.jpg', large_cover_url: '/tmp/monk_large.jpg', category: drama)
Video.create(title: "Family Guy", description: "A funny animated show about a dysfunctional family.", small_cover_url: '/tmp/family_guy.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "Futurama", description: "Pizza boy Philip J. Fry awakens in the 31st century after 1,000 years of cryogenic preservation in this animated series. After he gets a job at an interplanetary delivery service, Fry embarks on ridiculous escapades to make sense of his predicament.", small_cover_url: '/tmp/futurama.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "South Park", description: "A funny animated show about a four friends.", small_cover_url: '/tmp/south_park.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "Monk", description: "I have no idea what this show is about.", small_cover_url: '/tmp/monk.jpg', large_cover_url: '/tmp/monk_large.jpg', category: drama)
Video.create(title: "Family Guy", description: "A funny animated show about a dysfunctional family.", small_cover_url: '/tmp/family_guy.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "Futurama", description: "Pizza boy Philip J. Fry awakens in the 31st century after 1,000 years of cryogenic preservation in this animated series. After he gets a job at an interplanetary delivery service, Fry embarks on ridiculous escapades to make sense of his predicament.", small_cover_url: '/tmp/futurama.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "South Park", description: "A funny animated show about a four friends.", small_cover_url: '/tmp/south_park.jpg', large_cover_url: '/tmp/monk_large.jpg', category: comedy)
Video.create(title: "Monk", description: "I have no idea what this show is about.", small_cover_url: '/tmp/monk.jpg', large_cover_url: '/tmp/monk_large.jpg', category: drama)

