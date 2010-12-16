require 'json'
module Noid::Persistence
  class JSON < Base
    FILENAME = 'NOID.js'
    def initialize args = {}
      @file = args[:filename] || FILENAME
      data = load_json
      super data.merge(args)
      save
    end

    protected
    def load_json
      data = ::JSON.parse(File.read(@file)) if File.exists? @file
      data ||= {}
      data = data.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} unless data.empty?
      data[:counters] = data[:counters].map { |x| x.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} } if data[:counters]
      data[:identifier] = { :class => Kernel.const_get(data[:identifier]['class']) } if data[:identifier]
      data
    end

    def save
      File.open(@file, 'w') do |f|
          str = { :identifier => { :class => identifier }, :s => @s, :counters => @counters, :seed => @seed, }.to_json
        f.write(str)
      end
    end

  end
end
