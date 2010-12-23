require 'json'
module Noid::Persistence
  class JSON < Base
    FILENAME = 'NOID.js'
    def initialize args = {}
      @file = args[:filename] || FILENAME
      @json = args[:json] || File.read(@file) rescue nil
      data = load_json if @json
      data ||= {}
      super data.merge(args)
      save
    end

    protected
    def load_json
      data = ::JSON.parse(@json) rescue nil
      data ||= {}
      data = data.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} unless data.empty?
      data[:counters] = data[:counters].map { |x| x.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} } if data[:counters]
      data[:identifier] = { :class => Kernel.const_get(data[:identifier]['class']) } if data[:identifier]
      data
    end

    def save
      str = self.to_json
      File.open(@file, 'w') do |f|
        f.write(str)
      end unless @file == '/dev/null'

      str
    end

    def to_json
      str = { :template => @template, :identifier => { :class => identifier.name }, :s => @s, :counters => @counters, :seed => @seed }.to_json
    end

  end
end
