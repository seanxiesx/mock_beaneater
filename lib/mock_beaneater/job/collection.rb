module MockBeaneater
  class Jobs
    class << self
      attr_accessor :count
    end
    @count = 0
  end
end
