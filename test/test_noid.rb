require 'helper'

class TestNoid < Test::Unit::TestCase
  context "Noid" do
    should "generate checkdigits correctly" do
      n = Noid::Minter.new :template => 's.zd'
      assert_equal('q', n.send(:checkdigit, '13030/xf93gt2'))
    end

    should "generate max sequence for type 'r'" do
      n = Noid::Minter.new :template => 's.rd'
      assert_equal(0, n.send(:min))
      assert_equal(10, n.send(:max))

      n = Noid::Minter.new :template => 's.rdd'
      assert_equal(0, n.send(:min))
      assert_equal(100, n.send(:max))
    end

    should "generate quasi-random counters for type 'r'" do
      n = Noid::Minter.new :template => 's.rd'
      assert_equal((0..9).map { |x| {:value => x, :max => (x + 1)} }, n.send(:s))

      n = Noid::Minter.new :template => 's.rdde'
      s = n.send(:s)
      assert_contains(s, {:value => 2890, :max => 2900})
    end

    should "generate random sequence for type 'r'" do
      n = Noid::Minter.new :template => 's.rd' 
      a = 10.times.map { |i| n.mint }

      10.times do |i|
        assert_contains(a, "s#{i}")
      end

    end

    should "generate numeric sequence for type 's'" do
      n = Noid::Minter.new :template => 's.sd'
      10.times do |i|
        assert_equal("s#{i}", n.mint)
      end
    end

    should "generate extended sequence for type 's'" do
      n = Noid::Minter.new :template => 's.se'
      10.times do |i|
        assert_equal("s#{i}", n.mint)
      end
        assert_equal("sb", n.mint)
      10.times { n.mint }  
        assert_equal("sq", n.mint)

    end

    should "raise an exception when overflowing sequence" do
      n = Noid::Minter.new :template => 's.sd'
      10.times do |i|
        assert_equal("s#{i}", n.mint)
      end

      assert_raise Exception do
        n.mint
      end
    end

    should "generate sequence for type 's' with checkdigit" do
      n = Noid::Minter.new :template => 's.sdk'
      assert_equal('s0s', n.mint)
      assert_equal('s1v', n.mint)
      assert_equal('s2x', n.mint)
    end

    should "generate sequence for type 'z' with checkdigit" do
      n = Noid::Minter.new :template => 'z.zdk'
      assert_equal('z0z', n.mint)
      assert_equal('z11', n.mint)
      assert_equal('z23', n.mint)
    end
    should "generate sequence for type 'z', adding new digits as needed" do
      n = Noid::Minter.new :template => 'z.zdk'
      assert_equal('z0z', n.mint)
      assert_equal('z11', n.mint)
      assert_equal('z23', n.mint)
      10.times { n.mint }
      assert_equal('z13b', n.mint)
    end

    should "generate sequence for type 'z', adding new xdigits as needed" do
      n = Noid::Minter.new :template => 'z.zdek'
      assert_equal('z00z', n.mint)
      assert_equal('z012', n.mint)
      assert_equal('z025', n.mint)
      10.times { 
        assert_match(/^z[0-9]/, n.mint) 
      }
      assert_equal('z0f9', n.mint)
      100.times { 
        assert_match(/^z[0-9]/, n.mint) 
      }
      assert_equal('z3xz', n.mint)
      1000.times { 
        assert_match(/^z[0-9]/, n.mint) 
      }
      assert_equal('z38fs', n.mint)
    end

    should "validate 'r' digit sequences" do
      n = Noid::Minter.new :template => 'r.rd'

      assert_equal(true, n.valid?('r1')   )
      assert_equal(true, n.valid?('r9')  )
      assert_equal(false, n.valid?('r11')  )
      assert_equal(false, n.valid?('ro'))
      assert_equal(false, n.valid?('rb'))
    end

    should "validate 'r' xdigit sequences" do
      n = Noid::Minter.new :template => 'r.re'

      assert_equal(true, n.valid?('r1')   )
      assert_equal(true, n.valid?('r9')  )
      assert_equal(false, n.valid?('ro'))
      assert_equal(true, n.valid?('rb'))
    end
    should "validate 'r' xdigit + checkdigit sequences" do
      n = Noid::Minter.new :template => 'r.rek'

      assert_equal(true, n.valid?('r2w')   )
      assert_equal(false, n.valid?('r2b')  )
    end
  end
end
