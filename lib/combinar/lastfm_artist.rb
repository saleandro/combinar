module Combinar
  class LastfmArtist < Artist
    def initialize(hash)
      @hash = hash
    end

    def image
      @hash['image']
    end

    def mbids
      [@hash['mbid']]
    end

    def name
      @hash['name']
    end

    def play_count
      @hash['playcount']
    end
  end
end
