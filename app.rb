require 'sinatra'
require 'csv'
require 'twitter'
require 'dotenv'
Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

set :bind, '0.0.0.0'
set :views, Proc.new { File.join(root, "views") }
set :server, 'puma'

get '/' do
	erb :index
end

post '/' do
  content_type 'application/csv'
  attachment "arquivo.csv"
  
  tweets = []
  # client.filter(:track => params['terms'].join(",")) do |object|
  client.search(params['terms'], result_type: "recent").take(params['quantity'].to_i).each do |object|
    tweets << object.text if object.is_a?(Twitter::Tweet)
  end
  
  csv_string = CSV.generate do |csv|
    csv << ["Copyleft HugoJapaRicKenji - Todos esquerdo reservado"]
    tweets.each { |t| csv << [t] }
  end
end