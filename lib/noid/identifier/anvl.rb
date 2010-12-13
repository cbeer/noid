module Noid::Identifier
  class Anvl < Base
    def initialize id
      @id = id
      @metadata = ::ANVL::Document.new
    end

    def []= key, value
      super
      save
    end

    def push hash
      @metadata << hash
      save
    end

    private
    def file
      @id
    end

    def save
      File.open(file, 'w') do |f|
        f.write @metadata.to_s
      end

    end


  end
end
