require 'backports'
require 'backports'

module Noid
  class Minter
    attr_reader :seed, :seq
    attr_writer :counters

    def initialize args = {}
      @seq = 0
      seed(args[:seed], args[:seq])
      @template_string = args[:template]
      @max_counters = args[:max_counters]
      @counters = args[:counters]
    end  

    ##
    # Mint a new identifier
    def mint
      n = nil


      case template.generator
        when 's'
          n = next_in_sequence
        when 'z'
          n = next_in_sequence
        when 'r'
          raise Exception if counters.size == 0
          i = @rand.rand(counters.size)
          next_in_sequence
          n = counters[i][:value]
          counters[i][:value] += 1
          counters.delete_at(i) if counters[i][:value] == counters[i][:max]
      end

      template.mint(n)
    end

    ##
    # Noid identifier template
    #
    # @return Noid::Template
    def template
      @template ||= Noid::Template.new(@template_string)
    end

    ##
    # Is the identifier valid under the template string and checksum?
    # @param [String] id
    # @return bool
    def valid? id
      prefix = id[0..@prefix.length-1]
      ch = id[@prefix.length..-1].split('')
      check = ch.pop if @check
      return false unless prefix == @prefix

      return false unless @characters.length == ch.length
      @characters.each_with_index do |c, i|
        return false unless Noid::XDIGIT.include? ch[i] 
        return false if c == 'd' and ch[i] =~ /[^\d]/
      end

      return false unless check.nil? or check == checkdigit(id[0..-2])

      true
    end

    ##
    # Seed the random number generator with a seed and sequence offset
    # @param [Integer] seed
    # @param [Integer] seq
    # @return [Random]
    def seed seed = nil, seq = 0
      @rand = Random.new(seed) if seed
      @rand ||= Random.new 
      @seed = @rand.seed

      seq.times { @rand.rand } if seq

      @rand
    end

    def next_in_sequence
      n = @seq
      @seq += 1
      n
    end

    ##
    # Counters to use for quasi-random NOID sequences
    def counters
      return @counters if @counters
      return [] unless template.generator == "r"

      percounter = template.max / (@max_counters || Noid::MAX_COUNTERS) + 1
      t = 0
      @counters = []

      while t < template.max
        counter = {}
        counter[:value] = t
        counter[:max] = [t + percounter, template.max].min

        t += percounter

        @counters << counter
      end

      @counters
    end

    def dump
      { :seq => @seq, :seed => @seed, :template => template.template, :counters => Marshal.load(Marshal.dump(counters)) }
    end
  end
end
