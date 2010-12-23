module Noid::ActiveRecord
   module Provider
     def self.included base
       base.extend(ClassMethods)
       base.send :attr_accessor, :identifier_field
       base.send :attr_accessor, :minter
       base.send :before_create, :mint_identifier
     end

     def minter
       self.class.minter
     end

     def mint_identifier
       self.send "#{@identifier_field}=", self.minter.mint
     end

  end
end
