module MockBeaneater
  class Pool
    def tubes
      @tubes ||= Tubes.new(self)
    end
  end
end
