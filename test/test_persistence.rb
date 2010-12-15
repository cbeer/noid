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
        assert_equal(m.instance_variable_get('@s'), n.instance_variable_get('@s'))
        assert_equal(m.instance_variable_get('@mask'), n.instance_variable_get('@mask'))
        assert_equal(m.instance_variable_get('@characters'), n.instance_variable_get('@characters'))
        assert_equal(m.instance_variable_get('@rand').seed, n.instance_variable_get('@rand').seed)
        assert_equal(m.send(:s), n.send(:s))
        assert_equal(m.send(:min), n.send(:min))
        assert_equal(m.send(:max), n.send(:max))
        5.times { assert_equal(n.mint, m.mint) }
        assert_equal(6, m.send(:s))
      end
    end
  end
end
