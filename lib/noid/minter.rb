module Noid
  class Minter
    attr_reader :template, :seq
    attr_writer :counters

    def initialize(options = {})
      @template = Template.new(options[:template])

      @counters = options[:counters]
      @max_counters = options[:max_counters]

      # callback when an identifier is minted
      @after_mint = options[:after_mint]

      # used for random minters
      @rand = options[:rand] if options[:rand].is_a? Random
      @rand ||= Marshal.load(options[:rand]) if options[:rand]
      @rand ||= Random.new(options[:seed] || Random.new_seed)

      # used for sequential minters
      @seq = options[:seq] || 0
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

    def next_in_sequence
      if random?
        next_random
      else
        next_sequence
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

    def next_sequence
      seq.tap { @seq += 1 }
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
      {
        template: template.template,
        counters: Marshal.load(Marshal.dump(counters)),
        seq: seq,
        rand: Marshal.dump(@rand) # we would Marshal.load this too, but serializers don't persist the internal state correctly
      }
    end

    def random?
      template.generator == 'r'
    end
  end
end
