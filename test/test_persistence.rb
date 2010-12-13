require 'helper'
require 'fileutils'
require 'tmpdir'

class TestNoidPersistence < Test::Unit::TestCase
  context "Noid" do
    should "persist data using the JSON module" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Minter.new(:template => 's.sd', :persistence => Noid::Persistence::JSON)
        assert_equal('s0', n.mint)
        assert_equal(1, n.send(:s))
        n = Noid::Minter.new(:template => 's.sd', :persistence => Noid::Persistence::JSON)
        assert_equal('s1', n.mint)
        assert_equal(2, n.send(:s))
      end
    end
  end
end
