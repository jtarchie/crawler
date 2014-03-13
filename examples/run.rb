require_relative '../lib/crawler'
require 'sinatra'

$VERBOSE = true
Page.caching = true

start_url = 'http://www.joingrouper.com'
crawl = Crawler.new(start_url)

puts 'Crawling site for all pages and links'
crawl.process!

puts 'Drawing network graph'
JSON_OUTPUT = crawl.to_json

class ResultsApp < Sinatra::Base
  set :public_folder, './'

  get '/world.json' do
    JSON_OUTPUT
  end
end

ResultsApp.run!
