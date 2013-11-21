module MockBeaneater
  class Job
    attr_reader :id, :body, :connection, :reserved, :tube, :visible_at, :pri

    def initialize(body, tube, visible_at = Time.now.to_i, pri = 65536)
      @id = (Jobs.count += 1)
      @body = body
      @tube = tube
      @visible_at = visible_at
      @pri = pri
      @reserved = false
    end

    def release(options={})
      @reserved = false
      @tube.release(self)
      {:status => "RELEASED",
       :body => nil}
    end

    def delete
      @reserved = false
      @tube.delete(self)
      {:status => "DELETED",
       :body => nil}
    end

    def reserved?
      @reserved
    end

    def ==(other_job)
      @id == other_job.id
    end

    def to_s
      "#<MockBeaneater::Job id=#{@id} body=#{@body.inspect}>"
    end
    alias :inspect :to_s
  end
end
