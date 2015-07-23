require 'twitter'
require 'json'
require 'dotenv'
Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

users = []

Dir["./sources/BF/*.txt"].each do |file|
  username = file[/([\w]+).txt/][0...-7]
  begin
    sleep 0.3
    fetch = client.user(username)
    
    user = {
      username: username,
      followers: fetch.followers_count,
      following: fetch.friends_count
    }
    sleep 0.3
    user[:tweets] = client.user_timeline(username, count: 30).map { |t| t.text }
    users << user
  rescue Twitter::Error::TooManyRequests => error
    puts error.rate_limit.reset_in
  rescue Twitter::Error::Forbidden, Twitter::Error::NotFound => error
    File.delete(file)
    puts username
  rescue Twitter::Error::Unauthorized => error
    puts "nao autorizado #{username}"
  end
end

File.write("BF.json", users.to_json)