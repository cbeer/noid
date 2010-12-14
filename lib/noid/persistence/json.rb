require 'json'
module Noid::Persistence
  module JSON
    FILENAME = 'NOID.js'
    def setup_identifier args
      return super unless persisted_data
      @identifier_class = Kernel.const_get(persisted_data['@identifier_class']) 
    end

    def setup_mask args
      return super unless persisted_data
      persisted_data.reject { |k,v| k == '@identifier_class' }.each do |k, v|
        instance_variable_set(k, v)
      end

      @counters = @counters.map { |x| x.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}} if @counters

      if @seed
        @rand = Random.new
        @rand.srand @seed 
        @s.times { @rand.rand }
      end
    end

    def mint
      a = super
      save
      return a
    end

    protected
    def persisted_data
      @persisted_data ||= ::JSON.parse(File.read(FILENAME)) if File.exists? FILENAME
      @persisted_data
    end
    def save
      File.open(FILENAME, 'w') do |f|
          str = instance_variables_to_hash.to_json
        f.write(str)
      end
    end

    def instance_variables_to_hash
      h = {}
      instance_variables.reject { |x| x == '@rand' or x == '@persisted_data' }.each { |k| h[k] = instance_variable_get(k) }
      h
    end
  end
end
