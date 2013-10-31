require_relative '../spec_helper'

describe MockBeaneater::Tube do
  describe "#initialize" do
    before do
      @pool = double
      @name = 'tube'
    end
    subject { MockBeaneater::Tube.new(@pool, @name) }
    its(:pool)       { should == @pool }
    its(:name)       { should == @name }

    it "should instantiate a priority queue to hold delayed jobs" do
      tube = MockBeaneater::Tube.new(double, double)
      tube.instance_variable_get(:@delayed).should be_kind_of Containers::PriorityQueue
    end
    it "should instantiate a priority queue to hold ready jobs" do
      tube = MockBeaneater::Tube.new(double, double)
      tube.instance_variable_get(:@ready).should be_kind_of Containers::PriorityQueue
    end
    it "should instantiate an empty array to hold reserved jobs" do
      tube = MockBeaneater::Tube.new(double, double)
      tube.instance_variable_get(:@reserved).should == []
    end
  end

  describe "#put" do
    before { @tube = MockBeaneater::Tube.new(double, double) }
    it "should add job to ready container if no delay specified" do
      job_id = @tube.put('body', :pri => 12345)[:id]
      @tube.reserve.should do |j|
        j.id.should == job_id
        j.body.should == 'body'
        j.pri.should == 12345
      end
    end
    it "should add job to delayed container if delay specified" do
      job_id = @tube.put('body', :delay => 3)[:id]
      @tube.peek('delayed').should do |j|
        j.id.should == job_id
        j.body.should == 'body'
        j.pri.should == 65536
      end
    end
    it "should return hash with status, body (nil) and id" do
      @tube.put('body', :pri => 12345).should ==
        {:status => "INSERTED", :body => nil, :id => MockBeaneater::Jobs.count}
    end
  end

  describe "#peek" do
    before { @tube = MockBeaneater::Tube.new(double, double) }
    it "should refresh_tube" do
      @tube.should_receive(:refresh_tube).once
      @tube.peek('ready')
    end
    context "peeking at ready jobs" do
      it "should return next ready job if exists" do
        job_id = @tube.put('im-ready')[:id]
        @tube.put('im-ready-2')
        @tube.put('im-ready-3')
        @tube.peek('ready').id.should == job_id
      end
      it "should return nil if no ready job exists" do
        @tube.peek('ready').should be_nil
      end
    end
    context "peeking at delayed jobs" do
      it "should return next delayed job if exists" do
        @tube.put('im-delayed', :delay => 30)
        @tube.put('im-delayed-2', :delay => 40)
        job_id = @tube.put('im-delayed-3', :delay => 10)[:id]
        @tube.peek('delayed').id.should == job_id
      end
      it "should return nil if no delayed job exists" do
        @tube.peek('delayed').should be_nil
      end
    end
    it "should return nil if state is not 'ready' or 'delayed'" do
      @tube.peek('invalid_state').should be_nil
    end
  end

  describe "#clear" do
    it "should clear ready and delayed containers" do
      tube = MockBeaneater::Tube.new(double, double)
      5.times { tube.put('job') }
      tube.clear
      tube.peek('ready').should be_nil
      tube.peek('delayed').should be_nil
    end
  end

  describe "#delete" do
    it "should delete job from reserved container" do
      tube = MockBeaneater::Tube.new(double, double)
      tube.put 'job'
      tube.put 'job2'
      job = tube.reserve
      job2 = tube.reserve
      tube.instance_variable_get(:@reserved).should == [job, job2]
      job.delete
      tube.instance_variable_get(:@reserved).should == [job2]
    end
  end

  describe "#release" do
    it "should delete job from reserved container and add job to ready container" do
      tube = MockBeaneater::Tube.new(double, double)
      tube.put 'job'
      job = tube.reserve
      tube.instance_variable_get(:@reserved).should == [job]
      job.release
      tube.instance_variable_get(:@reserved).should == []
      tube.peek('ready').id.should == job.id
    end
  end

  describe "#refresh_tube" do
    it "should move jobs which should be visible from delayed to ready" do
      tube = MockBeaneater::Tube.new(double, double)
      job_id = tube.put('job')[:id]
      job2_id = tube.put('job2', :delay => 1)[:id]
      job3_id = tube.put('job3', :delay => 1)[:id]
      job4_id = tube.put('job4', :delay => 30)[:id]
      tube.peek('ready').id.should == job_id
      tube.instance_variable_get(:@ready).size.should == 1
      tube.peek('delayed').id.should == job2_id
      tube.instance_variable_get(:@delayed).size.should == 3
      sleep 2
      tube.send(:refresh_tube)
      tube.peek('ready').id.should == job_id
      tube.instance_variable_get(:@ready).size.should == 3
      tube.peek('delayed').id.should == job4_id
      tube.instance_variable_get(:@delayed).size.should == 1
    end
  end
end
