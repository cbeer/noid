module Noid::Identifier
  class Singleton < Base
    @@identifiers = {}
    @@identifiers = {}
    def self.new id
      @@identifiers[id] ||= super(id)
      @@identifiers[id]
    end

    def self.identifiers
      @@identifiers
    end
  end
end  
