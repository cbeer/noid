module Noid::Identifier
  class Singleton < Base
    @@identifiers = {}
    def self.new id
      @@identifiers[id] ||= super(id)
      @@identifiers[id]
    end
  end
end  
