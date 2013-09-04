require 'sinatra/base'

class MyApp < Sinatra::Base
  get '/' do
    "Hello, world"
  end
end

run MyApp
