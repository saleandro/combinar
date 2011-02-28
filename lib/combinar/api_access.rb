module ApiAccess
  class << self
    def json_from(url)
      JSON.parse(read_from(url))
    end

    private

    def read_from(url)
      begin
        sleep 1
#        puts url
        results = open(url).read
        @retry = 0
        results
      rescue OpenURI::HTTPError => e
        Stderr.puts "Error getting #{url}: #{e.message}"
        if e.message =~ /^503/
          sleep 1
          @retry = 0 unless @retry
          @retry += 1
          retry if @retry < 5
        end
        raise e
      end
    end
  end
end