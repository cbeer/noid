module Noid
  class Minter
    attr_reader :seed, :seq, :template
    attr_writer :counters

    def initialize(options = {})
      if options[:state]
        seed(options[:seed])
        @seq = options[:seq]
        @template_string = options[:template]
        @counters = options[:counters]
      else
        seed(options[:seed], options[:seq])
        @template_string = options[:template]
        @max_counters = options[:max_counters]
        @counters = options[:counters]

        @after_mint = options[:after_mint]
      end
      @template ||= Noid::Template.new(@template_string)
    end

    ##
    # Mint a new identifier
    def mint
      n = next_in_sequence
      id = template.mint(n)
      @after_mint.call(self, id) if @after_mint
      id
    end

    ##
    # Is the identifier valid under the template string and checksum?
    # @param [String] id
    # @return bool
    def valid?(id)
      template.valid?(id)
    end

    ##
    # Seed the random number generator with a seed and sequence offset
    # @param [Integer] seed
    # @param [Integer] seq
    # @return [Random]
    def seed(seed = nil, seq = 0)
      @rand = ::Random.new(seed) if seed
      @rand ||= ::Random.new
      @seed = @rand.seed
      @seq = seq || 0

      seq.times { next_random } if seq

      @rand
    end

    def next_in_sequence
      n = @seq
      @seq += 1
      case template.generator
      when 'r'
        n = next_random
      end
      n
    end

    def next_random
      raise 'Exhausted noid sequence pool' if counters.size == 0
      i = @rand.rand(counters.size)
      n = counters[i][:value]
      counters[i][:value] += 1
      counters.delete_at(i) if counters[i][:value] == counters[i][:max]
      n
    end

    ##
    # Counters to use for quasi-random NOID sequences
    def counters
      return @counters if @counters
      return [] unless template.generator == 'r'

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
      { state: true, seq: @seq, seed: @seed, template: template.template, counters: Marshal.load(Marshal.dump(counters)) }
    end
  end
end
