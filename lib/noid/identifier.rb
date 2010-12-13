module Noid::Identifier
  class Base
    @@identifiers = {}
    def self.new id
      @@identifiers[id] ||= super(id)
      @@identifiers[id]
    end

    def self.identifiers
      @@identifiers
    end

    def initialize id
      @id = id
      @metadata = {}
    end

    def id
      @id
    end

    def [] key
      @metadata[key]
    end

    def []= key, value
      @metadata[key] = value
    end

    def push hash
      @metadata.merge! hash
    end
  end
end
