class Noidtest < ActiveRecord::Base
  include Noid::ActiveRecord::Provider

  identifier_field :identifier
  minter Noid::Persistence::JSON.new(:template => 's.sdd', :filename => persistence_path)
end
