require 'helper'
require 'fileutils'
require 'tmpdir'

class TestNoidPersistence < Test::Unit::TestCase
  context "Noid" do
    should "persist data using the JSON module" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Persistence::JSON.new(:template => 's.sd')
        assert_equal('s0', n.mint)
        assert_equal(1, n.instance_variable_get('@s'))
        m = Noid::Persistence::JSON.new(:template => 's.sd')
        assert_equal('s1', m.mint)
        assert_equal(2, m.instance_variable_get('@s'))
      end
    end

    should "persist data in a supplied file" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Persistence::JSON.new(:template => 's.sd', :filename => 'NOID.json')
        assert(File.exists?('NOID.json'))
      end
    end

    should "persist seed data for random" do
      Dir.mktmpdir do |d|
        Dir.chdir d
        n = Noid::Persistence::JSON.new(:template => 'r.rd') 
        n.mint
        assert_equal(1, n.instance_variable_get('@s'))

        m = Noid::Persistence::JSON.new(:template => 'r.rd')
        assert_equal(n.instance_variable_get('@counters'), m.instance_variable_get('@counters'))
        assert_equal(n.instance_variable_get('@s'), m.instance_variable_get('@s'))
        assert_equal(n.instance_variable_get('@mask'), m.instance_variable_get('@mask'))
        assert_equal(n.instance_variable_get('@characters'), m.instance_variable_get('@characters'))
        assert_equal(n.instance_variable_get('@rand').seed, m.instance_variable_get('@rand').seed)
        assert_equal(n.send(:min), m.send(:min))
        assert_equal(n.send(:max), m.send(:max))
        5.times { assert_equal(n.mint, m.mint) }
        assert_equal(6, m.instance_variable_get('@s'))
      end
    end
  end
end
