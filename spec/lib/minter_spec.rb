require 'spec_helper'

describe Noid::Minter do
  it "should mint a few random 3-digit numbers" do
    minter = Noid::Minter.new(:template => '.rddd')
    expect(minter.mint).to match(/\d\d\d/)
  end

  it "should mint random 3-digit numbers, stopping after the 1000th" do
    minter = Noid::Minter.new(:template => '.rddd')
    1000.times { expect(minter.mint).to match(/^\d\d\d$/) }
    expect { minter.mint }.to raise_exception(RuntimeError, /Exhausted noid sequence pool/)
  end

  it "should mint sequential numbers without limit, adding new digits as needed" do
    minter = Noid::Minter.new(:template => '.zd')
    expect(minter.mint).to eq("0")
    999.times { expect(minter.mint).to match(/\d/) }
    expect(minter.mint).to eq("1000")
  end

  it "should mint random 4-digit numbers with constant prefix bc" do
    minter = Noid::Minter.new(:template => 'bc.rdddd')
    1000.times { expect(minter.mint).to match(/^bc\d\d\d\d$/) }
  end

  it "should mint sequential 2-digit numbers with constant prefix 8rf" do
    minter = Noid::Minter.new(:template => '8rf.sdd')
    expect(minter.mint).to eq("8rf00")
    10.times { expect(minter.mint).to match(/^8rf\d\d$/) }
    expect(minter.mint).to eq("8rf11")
    88.times { expect(minter.mint).to match(/^8rf\d\d$/) }
    expect { minter.mint }.to raise_exception(RuntimeError, /Exhausted noid sequence pool/)
  end

  it "should mint sequential extended-digits" do
    minter = Noid::Minter.new(:template => '.se')
    expect(29.times.map { minter.mint }.join('')).to eq("0123456789bcdfghjkmnpqrstvwxz")
  end

  it "should mint random 3-extended-digit numbers with constant prefix h9" do
    minter = Noid::Minter.new(:template => 'h9.reee')

    (minter.template.max).times { expect(minter.mint).to match(/^h9\w\w\w$/) }
    expect { minter.mint }.to raise_exception(RuntimeError, /Exhausted noid sequence pool/)
  end

  it "should mint unlimited sequential numbers with at least 3 extended digits" do
    minter = Noid::Minter.new(:template => '.zeee')
    (29*29*29).times { expect(minter.mint).to match(/^\w\w\w/) }
    expect(minter.mint).to match(/^\w\w\w\w/)
  end

  it "should mint random 7-char numbers, with extended digits at chars 2,4,and 5" do
    minter = Noid::Minter.new(:template => '.rdedeedd')
    1000.times { expect(minter.mint).to match(/^\d\w\d\w\w\d\d$/) }
  end

  it "should mint unlimited mixed digits, adding new extended digits as needed" do
    minter = Noid::Minter.new(:template => '.zedededed')
    expect(minter.mint).to eq("00000000")
  end

  it "should mint sequential 4-mixed-digit with constant prefix sdd" do
    minter = Noid::Minter.new(:template => 'sdd.sdede')
    expect(minter.mint).to eq('sdd0000')
    1000.times { expect(minter.mint).to match(/^sdd\d\w\d\w$/)}
    expect(minter.mint).to eq("sdd034h")
  end

  it "should mint random 3 mixed digits plus final (4th) computed check character" do
    minter = Noid::Minter.new(:template => '.rdedk')
    1000.times { expect(minter.mint).to match(/^\d\w\d\w$/) }
  end

  it "should mint 5 sequential mixed digits plus final extended digit check char" do
    minter = Noid::Minter.new(:template => '.sdeeedk')
    expect(minter.mint).to eq("000000")
    expect(minter.mint).to eq("000015")
    expect(minter.mint).to eq("00002b")
    1000.times { expect(minter.mint).to match(/^\d\w\w\w\d\w$/) }
    expect(minter.mint).to eq("003f3m")
  end

  it "should mint sequential digits plus check char, with new digits added as needed" do
    minter = Noid::Minter.new(:template => ".zdeek")
    expect(minter.mint).to eq("0000")
    expect(minter.mint).to eq("0013")
    (10*29*29-2).times { expect(minter.mint).to match(/^\d\w\w\w$/) }
    expect(minter.mint).to eq("10001")
  end

  it "should mint prefix plus random 3 mixed digits plus a check char" do
    minter = Noid::Minter.new(:template => "63q.redek")
    expect(minter.mint).to match(/63q\w\d\w\w/)
  end

  describe "validate" do
    it "should validate a prefixed identifier" do
      minter = Noid::Minter.new(:template => "foobar.redek")
      id = minter.mint
      expect(minter.valid?(id)).to eq(true)
    end
    it "should validate a prefixless identifier" do
      minter = Noid::Minter.new(:template => ".redek")
      id = minter.mint
      expect(minter.valid?(id)).to eq(true)
    end
    it "should validate with a new minter" do
      minter = Noid::Minter.new(:template => ".redek")
      id = minter.mint
      minter2 = Noid::Minter.new(:template => ".redek")
      expect(minter2.valid?(id)).to eq(true)
    end
  end

  describe "seed" do
    it "given a specific seed, identifiers should be replicable" do
      minter = Noid::Minter.new(:template => "63q.redek")
      minter.seed(1)
      expect(minter.mint).to eq("63q3706")

      minter = Noid::Minter.new(:template => "63q.redek")
      minter.seed(1)
      expect(minter.mint).to eq("63q3706")
    end

    it "given a specific seed and sequence, identifiers should be replicable" do
      minter = Noid::Minter.new(:template => "63q.redek")
      minter.seed(23456789, 567)
      mint1 = minter.mint
      dump1 = minter.dump

      minter = Noid::Minter.new(:template => "63q.redek")
      minter.seed(23456789, 567)
      mint2 = minter.mint
      dump2 = minter.dump
      expect(dump1).to eql(dump2)
      expect(mint1).to eql(mint2)
      expect(mint1).to eq("63qb41v") # "63qh305" was the value from a slightly buggy impl
    end
  end

  describe "dump and reload" do
    it "should dump the minter state" do
      minter = Noid::Minter.new(:template => ".sddd")
      d = minter.dump
      expect(d[:template]).to eq(".sddd")
      expect(d[:seq]).to eq(0)

      minter.mint
      minter.mint
      d = minter.dump
      d[:seq] == 2
    end

    it "should dump the seed, sequence, and counters for the RNG" do
      minter = Noid::Minter.new(:template => ".rddd")
      d = minter.dump
      d[:seq] == 0
      expect(d[:seed]).to eq(minter.instance_variable_get('@seed'))
    end

    it "should allow a random identifier minter to be 'replayed' accurately" do
      minter = Noid::Minter.new(:template => '.rd')
      d = minter.dump
      arr = 10.times.map { minter.mint }

      minter = Noid::Minter.new(d)

      arr2 = 10.times.map { minter.mint }

      expect(arr).to eq(arr2)

    end

  end

  describe "with large seeds" do
    it "should not reproduce noids with constructed sequences" do
      minter = Noid::Minter.new(:template => 'ldpd:.reeeeeeee')
      minter.seed(192548637498850379850405658298152906991)
      first_values = (1..1000).collect {|c| minter.mint}

      values = []
      (0..999).each do |i|
        minter = Noid::Minter.new(:template => 'ldpd:.reeeeeeee')
        minter.seed(192548637498850379850405658298152906991, i)
        values << minter.mint
        expect(values[i]).to eql first_values[i]
      end
      values.uniq!
      expect(values.length).to eql 1000
    end
  end

  describe "multithreading-safe example" do
    before do
      require 'yaml'
      minter = Noid::Minter.new(:template => '.rd')
      yaml = YAML::dump(minter.dump)
      File.open('minter-state', 'w') { |f| f.write yaml }
    end

    after do
      File.delete('minter-state')
    end

    it "should persist state to the filesystem" do

      File.open("minter-state", File::RDWR|File::CREAT, 0644) {|f|
        f.flock(File::LOCK_EX)
        yaml = YAML::load(f.read)

        minter = Noid::Minter.new(yaml)

        f.rewind
        yaml = YAML::dump(minter.dump)
        f.write yaml
        f.flush
        f.truncate(f.pos)
      }

    end
  end

end
