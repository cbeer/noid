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

    should "persist seed data for random" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Minter.new(:template => 'r.rd', :persistence => Noid::Persistence::JSON)
        n.mint
        assert_equal(1, n.send(:s))

        m = Noid::Minter.new(:template => 's.sd', :persistence => Noid::Persistence::JSON)
        assert_equal(m.instance_variable_get('@counters'), n.instance_variable_get('@counters'))
        assert_equal(m.instance_variable_get('@rand').seed, n.instance_variable_get('@rand').seed)
        id = n.mint
        assert_equal(id, m.mint)
        assert_equal(2, m.send(:s))
      end
    end
  end
end
