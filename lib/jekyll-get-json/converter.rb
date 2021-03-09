require "jekyll"
require 'json'
require 'deep_merge'
require 'open-uri'

module JekyllGetJson
  class GetJsonGenerator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)

      config = site.config['jekyll_get_json']
      if !config
        warn "No config".yellow
        return
      end
      if !config.kind_of?(Array)
        config = [config]
      end

      config.each do |d|
        begin
          target = site.data[d['data']]
          source = JSON.load(URI.open(d['json']))

          if target
            target.deep_merge(source)
          else
            site.data[d['data']] = source
          end

     if d['cache']
       data_source = (site.config['data_source'] || '_data')
       path = "#{data_source}/#{d['data']}.json"
       open(path, 'wb') do |file|
         file << JSON.generate(site.data[d['data']])
       end
        rescue
          next
        end
      end
    end
  end
end
