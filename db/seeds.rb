# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Faker::Config.locale = "ru"

user = User.find_or_create_by!(email: "nikolaokonesh@gmail.com", slug: "nikolaokonesh")
user.add_role "admin"

5.times do |i|
  User.create!(email: Faker::Internet.email, name: Faker::Name.name)
  puts "User + #{i}"
end

categories = ListingsDictionary::ACTIONS.keys

50.times do |i|
  random_category = categories.sample
  post = Post.create!(content: "#{random_category} #{Faker::Lorem.paragraph}")
  Entry.create!(user_id: User.all.sample.id, entryable: post)
  puts "Post + #{i}"
end

entry_post = Entry.all

entry_post.each do |entry|
  puts "Entry + #{entry.id}"
  100.times do |i|
    comment = Comment.create!(content: "+#{i} коммент id #{entry.id}")
    Entry.create!(user_id: User.all.sample.id, parent: entry, entryable: comment)
    puts "Comments + #{i}"
  end
end
