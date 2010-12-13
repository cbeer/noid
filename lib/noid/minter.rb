module Noid
  class Minter

    XDIGIT = ['0','1','2','3','4','5','6','7','8','9','b','c','d','f','g','h','j','k','l','n','p','q','r','s','t','v','w','x','z']
    MAX_COUNTERS = 293

    def initialize args = {}
      @max = nil
      @min = nil
      @identifier_class = nil
      setup_persistence args
      setup_identifier args
      setup_mask args
    end  


    def mint
      str = @prefix
      case @type
        when 's'
          n = @s
          @s += 1
          str += n2xdig(n)
        when 'z'
          n = @s
          @s += 1
          str += n2xdig(n)
        when 'r'
          i = rand(@s.size)
          n = @s[i][:value]
          @s[i][:value] += 1
          @s.delete_at(i) if @s[i][:value] == @s[i][:max]
          str += n2xdig(n)
      end

      str += checkdigit(str) if @check

      @identifier_class.new str
    end

    def valid? id
      prefix = id[0..@prefix.length-1]
      ch = id[@prefix.length..-1].split('')
      check = ch.pop if @check
      return false unless prefix == @prefix

      return false unless @characters.length == ch.length
      @characters.each_with_index do |c, i|
        return false unless XDIGIT.include? ch[i] 
        return false if c == 'd' and ch[i] =~ /[^\d]/
      end

      return false unless check.nil? or check == checkdigit(id[0..-2])

      true
    end

    protected
    def s
      @s
    end

    def checkdigit str
      i = 1
      XDIGIT[str.split('').map { |x|  XDIGIT.index(x).to_i }.inject { |sum, n| i+=1; sum += (n * i) } % XDIGIT.length]
    end

    def min
      return @min if @min
      @min = 0
    end

    def max
      return @max if @max
      return @max = nil if @type == 'z'
      @max = @characters.inject(1) do |sum, n|
        i = case n
            when 'e'
              XDIGIT.length
            when 'd'
              10
            else 
              1
        end
        sum *= i 
      end  
    end

    def n2xdig n
      xdig = @characters.reverse.map do |c|
        div = case c
          when 'e' then XDIGIT.length
          when 'd' then 10  
          end
          next if div.nil?

          value = n % div
          n = n / div
          XDIGIT[value]
      end.compact.join ''

      if @type == 'z'
        while n > 0
          c = @characters.last
          div = case c
            when 'e' then XDIGIT.length
            when 'd' then 10  
            end
            next if div.nil?

            value = n % div
            n = n / div
            xdig += XDIGIT[value]
        end
      end
      
      raise Exception if n > 0

      xdig.reverse
    end

    def setup_identifier args
      @identifier_class = args[:identifier_class]
      @identifier_class ||= String
    end

    def setup_persistence args
      self.extend args[:persistence] if args[:persistence]
    end

    def setup_mask args
      @prefix, @mask = args[:template].split('.')

      @prefix = "#{args[:namespace]}/#{@prefix}" if args[:namespace]

      @type, @characters = @mask.split '', 2
      @characters = @characters.split ''
      @check = @characters.pop and true if @characters.last == 'k'
      case @type
        when 's'
          @s = 0
        when 'z'
          @s = 0
        when 'r'

          percounter = max / MAX_COUNTERS + 1
          t = 0
          @s = Array.new(max/percounter) do |i| 
            { :value => case i
              when 0 then 0
              else t += percounter 
              end, :max => t + percounter }
          end
      end
      
      
    end
  end
end
