require 'sinatra'
require 'json'
require 'mongoid'

class API < Sinatra::Base

  # MongoDB configuration
  Mongoid.configure do |config|
    if ENV['MONGOHQ_URL']
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      uri = URI.parse(ENV['MONGOHQ_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    else
      config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('test')
    end
  end

  # Models
  class Counter
    include Mongoid::Document

    field :count_yes, :type => Integer
    field :count_no, :type => Integer

    def self.increment_yes
      c = first || new({:count_yes => 0})
      c.inc(:count_yes, 1)
      c.save
      c.count
    end

    def self.increment_no
      c = first || new({:count_no => 0})
      c.inc(:count_no, 1)
      c.save
      c.count
    end
  end

  get '/sushi.json' do
    content_type :json

    {:sushi => ["Maguro", "Hamachi", "Uni", "Saba", "Ebi", "Sake", "Tai"]}.to_json
  end


  get '/report' do

    counter = Counter.first()
    #content_type 'application/json'
    yesCount =counter.count_yes
    noCount =counter.count_no

    resp = "yes:" + yesCount.to_s + ", no:"+ noCount.to_s
  end

  post '/action' do
    #response = JSON.parse(request.body.read)
    response = request.body.read
    if response == "yes"
      Counter.increment_yes
    else
      Counter.increment_no
    end
    'sucess'

  end

  get '/sass_css/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(:"/stylesheets/#{params[:name]}")
  end

  get '/' do
    erb :index
  end
end
