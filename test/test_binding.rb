require 'helper'
require 'anvl'
require 'tmpdir'

class TestNoidBinding < Test::Unit::TestCase
  context "Noid" do
    should "accept identifier_class for NOID bindings" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Minter.new :template => 'r.rek', :identifier_class => Noid::Identifier::Base
        id = n.mint
        assert_equal(Noid::Identifier::Base, id.class)
        id['abc'] = 123
        assert_equal(123, id['abc'])
      end
    end

    should "use singleton instance to persist  NOID bindings" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Minter.new :template => 'r.rek', :identifier_class => Noid::Identifier::Singleton
        id = n.mint
        id['abc'] = 123
        assert_equal(123, id['abc'])

        id2 = Noid::Identifier::Singleton.new id.id
        assert_equal(123, id2['abc'])
      end
    end

    should "user anvl instance to persist NOID binding info" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Minter.new :template => 'r.rek', :identifier_class => Noid::Identifier::Anvl
        id = n.mint
        id['abc'] = "123"
        assert_equal(Noid::Identifier::Anvl, id.class)
        assert_equal("123", id['abc'])
      end  
    end
  end
end
