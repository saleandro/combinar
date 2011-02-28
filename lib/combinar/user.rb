module Combinar
  class User
    attr_reader :username

    def initialize(username)
      @username = username
    end

# TODO: festival_catalog_id
    def artists_i_love(artists)
      artists_love = artists.map do |a|
        lastfm_artist = lastfm_library.select {|lastfm| lastfm == a}
        if lastfm_artist.first
          a.play_count = lastfm_artist.first.play_count
          a
        end
      end.compact
      artists_love.sort_by {|a| a.play_count}.reverse
    end

    def artists_i_will_love(catalog_id)
      similar_hash = {}
      lastfm_library[0..25].each_slice(5) do |batch|
        Artist.similar_artists_in(catalog_id, batch).each do |a|
          similar_hash[a.id] ||= []
          similar_hash[a.id] << a
        end
      end

      similar_artists = similar_hash.values.sort_by{|a| a.size}.reverse.map {|a| a.first}

      select_artists_i_dont_know(similar_artists)
    end
    
    def artists_i_will_hate(catalog_id)
      dissimilar_hash = {}
      lastfm_library[0..25].each_slice(5) do |batch|
        Artist.dissimilar_artists_in(catalog_id, batch).each do |a|
          dissimilar_hash[a.id] ||= []
          dissimilar_hash[a.id] << a
        end
      end

      dissimilar_artists = dissimilar_hash.values.sort_by{|a| a.size}.reverse.map {|a| a.first}

      select_artists_i_dont_know(dissimilar_artists)
    end
  
    def upcoming_festivals
      return @festivals if @festivals

      sk_user = Songkicky::User.find_by_username(@username)
      @festivals = sk_user.upcoming_events.select {|e| e.festival? }
    end
    
    private
    
    def select_artists_i_dont_know(artists)
      artists.map do |a|
        lastfm_artist = lastfm_library.select {|lastfm| lastfm == a }
        a if lastfm_artist.first.nil?
      end.compact
    end
    
    def lastfm_library
      return @library if @library

      unless library = Combinar.store.get(library_storage_key)
        library_url = "http://ws.audioscrobbler.com/2.0/?method=library.getartists&user=#{@username}&api_key=#{Combinar.api_key('lastfm')}&limit=500&format=json"
        json = ApiAccess.json_from(library_url)
        library = json['artists']['artist'].map do |a|
          { 'mbid' => a['mbid'], 
            'playcount' => a['playcount'].to_i, 
            'name' => a['name'], 
            'image' => a['image'].select {|i| i['size'] == 'large'}.first['#text']
           }
        end

        Combinar.store.put(library_storage_key, library.to_json)
      else
        library = JSON.parse(library)
      end

      @library = library.map {|hash| LastfmArtist.new(hash)}
    end
    
    def library_storage_key
      "user_library_#{@username}"
    end

  end
end