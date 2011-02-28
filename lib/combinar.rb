require 'rubygems'
require 'open-uri'
require 'json'
require 'rexml/document'
require 'enumerator'
require 'songkicky'
require 'redis'
require 'pp'

lib_folder = File.dirname(__FILE__) + '/combinar'

require lib_folder + '/api_access'
require lib_folder + '/user'
require lib_folder + '/artist'
require lib_folder + '/echonest_artist'
require lib_folder + '/lastfm_artist'
require lib_folder + '/event'

module Combinar
  class << self
    def store
      Combinar::WebScaleStore
    end
  
    def api_key(service)
      config['api_keys'][service]
    end
  
    def config
      @config ||= YAML.load_file(File.dirname(__FILE__) + '/../config.yml')
    end
  end

  module WebScaleStore
    def self.get(key)
    end

    def self.put(key, value)
    end
  end

  module RedisStore
    def self.get(key)
      db.get(key)
    end

    def self.put(key, value)
      db[key] = value
    end

    private

    def self.db
      @db ||= Redis.new(:thread_safe => true)
    end
  end
end

Songkicky.apikey = Combinar.api_key('songkick')

