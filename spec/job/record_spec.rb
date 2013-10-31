require_relative '../spec_helper'

describe MockBeaneater::Job do
  describe "#initialize" do
    before { @tube = double }
    subject { MockBeaneater::Job.new('body', @tube) }
    its(:id)         { should == MockBeaneater::Jobs.count }
    its(:body)       { should == 'body' }
    its(:tube)       { should == @tube }
    its(:visible_at) { should be_within(1).of(Time.now.to_i) }
    its(:reserved)   { should be_false }

    it "should assign each job a unique id through incrementing Jobs.count" do
      current_count = MockBeaneater::Jobs.count
      MockBeaneater::Job.new('body', double).id.should == current_count + 1
      MockBeaneater::Job.new('body', double).id.should == current_count + 2
    end
  end

  describe "#release" do
    it "should set reserved to false" do
      job = MockBeaneater::Job.new('body', double(:release => true))
      job.instance_variable_set(:@reserved, true)
      job.release
      job.should_not be_reserved
    end
    it "should request for tube to release self" do
      tube = double
      job = MockBeaneater::Job.new('body', tube)
      tube.should_receive(:release).with(job)
      job.release
    end
  end

  describe "#delete" do
    it "should set reserved to false" do
      job = MockBeaneater::Job.new('body', double(:delete => true))
      job.instance_variable_set(:@reserved, true)
      job.delete
      job.should_not be_reserved
    end
    it "should request for tube to delete self" do
      tube = double
      job = MockBeaneater::Job.new('body', tube)
      tube.should_receive(:delete).with(job)
      job.delete
    end
  end

  describe "#reserved?" do
    it "should return reserved status" do
      job = MockBeaneater::Job.new('body', double)
      [true, false].each do |status|
        job.instance_variable_set(:@reserved, status)
        job.reserved?.should == status
      end
    end
  end

  describe "#==" do
    it "should be equal if both jobs have the same id" do
      job = MockBeaneater::Job.new('body', double)
      job2 = MockBeaneater::Job.new('body', double)
      job2.instance_variable_set(:@id, job.id)
      job.should == job2
    end
    it "should not be equal if both jobs have different ids" do
      job = MockBeaneater::Job.new('body', double)
      job2 = MockBeaneater::Job.new('body', double)
      job.should_not == job2
    end
  end

  describe "#to_s" do
    it "should output only job id and body" do
      job = MockBeaneater::Job.new('body', double)
      job.to_s.should == "#<MockBeaneater::Job id=#{job.id} body=#{job.body.inspect}>"
    end
  end
end
