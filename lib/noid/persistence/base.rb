module Noid::Persistence
  class Base
    include Noid::Base

    def mint
      a = super
      save
      return a
    end
  end
end
