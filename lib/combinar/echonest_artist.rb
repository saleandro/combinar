module Combinar
  class EchonestArtist < Artist
    def initialize(hash)
      @hash = hash
    end

    def name
      @hash['name']
    end

    def mbids
      return [] unless @hash['foreign_ids']
      [@hash['foreign_ids'].first['foreign_id'].split(':').last]
    end

    def id
      @hash['id']
    end
  end
end