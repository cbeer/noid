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
      persisted_data.reject { |k,v| k == '@persisted_data' or k == '@identifier_class' }.each do |k, v|
        instance_variable_set(k, v)
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
        f.write(Hash[*instance_variables.reject { |x| x == '@persisted_data' }.map { |k| [k, instance_variable_get(k)]}.flatten].to_json)
      end
    end
  end
end
