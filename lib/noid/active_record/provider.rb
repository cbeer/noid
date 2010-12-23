module Noid::ActiveRecord
   module Provider
     def self.included base
       base.send :before_create, :mint_identifier
    #   base.send :attr_accessor, :minter
       class << base
         def minter value = nil
           @minter = value if value
           @minter
         end

         def identifier_field value = nil
           @identifier_field = value if value
           @identifier_field
         end

         def persistence_path
           File.join RAILS_ROOT, "db/#{self.to_s}_NOID.js"
         end
       end
     end

     def minter= value
       @minter = value
     end

     def minter
       @minter || self.class.minter
     end

     def mint_identifier
       self.send "#{self.class.instance_variable_get('@identifier_field')}=", self.minter.mint unless self.attribute_present? self.class.instance_variable_get('@identifier_field')
     end

  end
end
