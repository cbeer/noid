module Noid
  class Minter
    attr_reader :seed, :seq, :template
    attr_writer :counters

    def initialize(options = {})
      if options[:state]
        # Only set the sequence ivar if this is a stateful minter
        @seq = options[:seq]
      else
        @max_counters = options[:max_counters]
        @after_mint = options[:after_mint]
      end
      @counters = options[:counters]
      @template = Template.new(options[:template])
      seed(options[:seed], options[:seq])
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
    # @return [Random]
    def seed(seed_number = nil, seq = 0)
      @rand = seed_number ? Random.new(seed_number) : Random.new
      @seed = @rand.seed
      @seq = seq || 0

      seq.times { next_random } if seq

      @rand
    end

    def next_in_sequence
      n = @seq
      @seq += 1
      if template.generator == 'r'
        next_random
      else
        n
      end
    end

    def next_random
      raise 'Exhausted noid sequence pool' if counters.size == 0
      i = random_bucket
      n = counters[i][:value]
      counters[i][:value] += 1
      counters.delete_at(i) if counters[i][:value] == counters[i][:max]
      n
    end

    def random_bucket
      @rand.rand(counters.size)
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
