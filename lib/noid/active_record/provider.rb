module Noid::ActiveRecord
   module Provider
     def self.included base
       base.extend(ClassMethods)
       base.send :before_create, :mint_identifier
     end

     module ClassMethods
       def identifier_field value
         @@identifier_field = value
       end

       def minter value
         @@minter = value
       end
     end

     def minter
       @@minter
     end

     def mint_identifier
       self.send "#{@@identifier_field}=", self.minter.mint
     end

  end
end
