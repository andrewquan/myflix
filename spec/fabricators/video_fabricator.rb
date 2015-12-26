Fabricator(:video) do
  title { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph(2) }
end