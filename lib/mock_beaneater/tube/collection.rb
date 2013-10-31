module MockBeaneater
  class Tubes
    attr_reader :pool, :all, :watched, :used

    def initialize(pool)
      @pool = pool
      @all = [Tube.new(@pool, 'default')]
      @watched = [find('default')]
      @used = find('default')
    end

    def find(tube_name)
      first_or_create(tube_name)
    end
    alias_method :[], :find

    def reserve(timeout=nil)
      job = nil
      @all.each do |t|
       if t.peek('ready')
         job = t.reserve(timeout)
         break
       end
      end
      job
    end

    def watch(*names)
      names.each do |n|
        @watched << first_or_create(n)
      end
    end

    def watch!(*names)
      @watched = []
      names.each do |n|
        @watched << first_or_create(n)
      end
    end

    def use(tube_name)
      @used = first_or_create(tube_name)
    end

    def first_or_create(tube_name)
      @all.find { |t| t.name == tube_name } || (@all << Tube.new(@pool, tube_name)).last
    end
  end
end
