module MockBeaneater
  class Tube
    attr_reader :pool, :name

    def initialize(pool, name)
      @name = name.to_s
      @pool = pool
      @delayed = Containers::PriorityQueue.new
      @ready = Containers::PriorityQueue.new
      @reserved = []
    end

    def put(body, options={})
      visible_at = (options[:delay] || 0) + Time.now.to_i
      job = Job.new(body, self, visible_at, options[:pri] || 65536)
      if options[:delay]
        @delayed.push job, -1*visible_at
      else
        @ready.push job, job.pri
      end
      {:status => "INSERTED",
       :body   => nil,
       :id     => job.id}
    end

    def peek(state)
      refresh_tube
      if state == 'ready'
        @ready.next
      elsif state == 'delayed'
        @delayed.next
      else
        nil
      end
    end

    def reserve(timeout=nil)
      refresh_tube
      @ready.pop.tap { |j| @reserved << j if j }
    end

    def clear
      @delayed.clear
      @ready.clear
    end

    def delete(job)
      @reserved.delete(job)
    end

    def release(job)
      @reserved.delete(job)
      @ready.push(job, job.pri)
    end

    def to_s
      "#<MockBeaneater::Tube name=#{@name.inspect}>"
    end
    alias :inspect :to_s

    private

    def refresh_tube
      while @delayed.next && @delayed.next.visible_at < Time.now.to_i
        job = @delayed.pop
        @ready.push job, job.pri
      end
    end
  end
end
