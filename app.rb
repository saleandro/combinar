require File.dirname(__FILE__) + '/lib/combinar'
require 'sinatra'

get '/users/:username' do
  user = Combinar::User.new(params['username'])
  @festivals = user.upcoming_festivals
  erb :festivals
end

get '/users/:username/festivals/:id/:tab' do
  user = Combinar::User.new(params['username'])
  @festival = Combinar::Event.new(params[:id])
  @festival.artists

  @tab = params[:tab]

  case @tab
  when 'love'
    @artists = user.artists_i_love(@festival.artists)
  when 'hotttness'
    @artists = user.artists_i_will_love(@festival.echonest_catalog_id)
  when 'beer'
    @artists = user.artists_i_will_hate(@festival.echonest_catalog_id)
  else
    @artists = LastfmArtist.new({
      'mbid' => 'e0140a67-e4d1-4f13-8a01-364355bee46e', 
      'name' => 'Oh noes.', 
      'image' => 'http://c3.ac-images.myspacecdn.com/images01/46/l_7eacf9b767cdc8b3480a9fb9eda6108e.jpg'})
  end

  erb :festival
end
