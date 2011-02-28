module Combinar
  class Artist
    attr_accessor :mp3,   :play_count
    attr_accessor :image, :hotttness
    
    class << self
      
      def similar_artists_in(catalog_id, artists, dissimilar=false)
        ids = []
        names = []

        artists.each do |artist|
          if artist.mbids.empty? || artist.mbids.first.nil? || artist.mbids.first == ''
            names << artist.name
          else
            ids << "musicbrainz:artist:#{artist.mbids.first}"
          end
        end

        id_param = ids.any? ? '&' + ids.map{|n| 'id='+URI.encode(n) }.join('&') : ''
        names = names.any? ? '&' + names.map{|n| 'name='+URI.encode(n) }.join('&') : ''

        url = "http://developer.echonest.com/api/v4/artist/similar?api_key=#{Combinar.api_key('echonest')+names+id_param}&bucket=id:#{catalog_id}&bucket=id:musicbrainz&bucket=hotttnesss&limit=true&format=json"
        url += '&reverse=true' if dissimilar
        json = ApiAccess.json_from(url)
        (json['response']['artists']||[]).map {|h| EchonestArtist.new(h)}
      end
      
      def dissimilar_artists_in(catalog_id, artists)
        similar_artists_in(catalog_id, artists, true)
      end
    end

    def initialize(songkick_artist)
      @songkick_artist = songkick_artist
    end

    def hotttness
      return @hotttness if @hotttness

      id_param = echonest_id_param
      return unless id_param

      url = "http://developer.echonest.com/api/v4/artist/hotttnesss?api_key=#{Combinar.api_key('echonest')}&#{id_param}&format=json"
      json = ApiAccess.json_from(url)
      @hotttness = json['response']['artist'] ? json['response']['artist']['hotttnesss'] : 0
    end

    def image
      image = Combinar.store.get(image_storage_key)

      unless image
        json = ApiAccess.json_from("http://ws.audioscrobbler.com/2.0/?method=artist.getInfo&api_key=#{Combinar.api_key('lastfm')}&#{lastfm_id_param}&format=json")
        image = json['artist'] ? json['artist']['image'].select {|i| i['size'] == 'large'}.first['#text'] : ''
        Combinar.store.put(image_storage_key, image)
      end

      image
    end

    def method_missing(sym, *args, &block)
      return @songkick_artist.send(sym, *args, &block) if @songkick_artist.respond_to?(sym)
      super(sym, args, block)
    end
    
    def ==(other)
      ((mbids.first && mbids.first == other.mbids.first) || name == other.name)
    end

    def echonest_catalog_id
      mbids.first||name
    end    

    private
    
    def image_storage_key
      "artist_profile_image_#{echonest_catalog_id}"
    end
    
    def lastfm_id_param
      if mbids.empty?
        'artist='+URI.encode(name)
      else
        'mbid='+mbids.first
      end
    end
      
    def echonest_id_param
      if mbids.empty?
        artist_id = echonest_id_by_name(name)
        return unless artist_id

        "id=#{artist_id}"
      else
        "id=musicbrainz:artist:#{mbids.first}"
      end
    end

    def echonest_id_by_name(name)
      url = "http://developer.echonest.com/api/v4/artist/search?api_key=#{Combinar.api_key('echonest')}&name=#{URI.encode(name)}&format=json"
      json = ApiAccess.json_from(url)
      json['response']['artists'].first['id'] if json['response']['artists'].any?
    end
  end

end

