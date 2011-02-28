module Combinar
  class Event
    
    def initialize(songkick_id)
      @songkick_event = Songkicky::Event.find_by_id(songkick_id)
    end

    def id
      @songkick_event.id
    end
    
    def echonest_catalog_id
      "CAKMDXJ12E1C44E436"
    end
    
    def artists
      return @artists if @artists

      artists = @songkick_event.artists.map {|a| Combinar::Artist.new(a)}

      echonest_data = []
      start = 0
      json = {}
      while start == 0 or json['response']['catalog']['items'].any?
        url = "http://developer.echonest.com/api/v4/catalog/read?api_key=#{Combinar.api_key('echonest')}&format=json&id=#{echonest_catalog_id}&bucket=audio&bucket=hotttnesss&results=100&start=#{start}"
        json = ApiAccess.json_from(url)
        echonest_data += json['response']['catalog']['items']
        start += 100
      end

      @artists = echonest_data.map do |item|
        artist = artists.select {|a| (echonest_catalog_id + '_' + a.echonest_catalog_id) == item['request']['item_id']}.first
        artist.hotttness = item['hotttnesss']
        artist.mp3 = item['audio'].first['url'] if item['audio'] && item['audio'].any?
        artist
      end
    end

    def method_missing(sym, *args, &block)
      return @songkick_event.send(sym, *args, &block) if @songkick_event.respond_to?(sym)
      super(sym, args, block)
    end
    
  end
  
end
