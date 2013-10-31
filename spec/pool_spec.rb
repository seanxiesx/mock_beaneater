require_relative 'spec_helper'

describe MockBeaneater::Pool do
  describe "#tubes" do
    before { @pool = MockBeaneater::Pool.new }
    it "should return an instance of tubes" do
      @pool.tubes.should be_kind_of MockBeaneater::Tubes
    end
    it "should return tubes with reference to self" do
      @pool.tubes.pool.should == @pool
    end
    it "should return same instance of tubes when called multiple times" do
      @pool.tubes.should == @pool.tubes
    end
  end
end
