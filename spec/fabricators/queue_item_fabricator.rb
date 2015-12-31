Fabricator(:queue_item) do
  position { (1..3).to_a.sample }
end