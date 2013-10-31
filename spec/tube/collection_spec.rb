require_relative '../spec_helper'

describe MockBeaneater::Tubes do
  describe "#initialize" do
    before do
      @pool = double
      @default_tube = MockBeaneater::Tube.new(@pool, 'default')
      MockBeaneater::Tube.stub(:new).and_return(@default_tube)
    end
    subject { MockBeaneater::Tubes.new(@pool) }
    its(:pool)       { should == @pool }
    its(:all)        { should == [@default_tube] }
    its(:watched)    { should == [@default_tube] }
    its(:used)       { should == @default_tube }
  end

  describe "#[]" do
    it "should first_or_create tube with name:tube_name" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_name = 'tube'
      tubes.should_receive(:first_or_create).with(tube_name)
      tubes[tube_name]
    end
  end

  describe "#find" do
    it "should first_or_create tube with name:tube_name" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_name = 'tube'
      tubes.should_receive(:first_or_create).with(tube_name)
      tubes.find(tube_name)
    end
  end

  describe "#reserve"do
    it "should return job if any in watched tubes are ready"
  end

  describe "#watch" do
    it "should add names to watch list" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_names = ['watch-me', 'watch-me-too']
      tubes.watched.should == [tubes.find('default')]
      tubes.watch(*tube_names)
      tubes.watched.should == [tubes.find('default'), tubes.find(tube_names.first), tubes.find(tube_names.last)]
    end
  end

  describe "#watch!" do
    it "should set watch list to tubes with names" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_names = ['watch-me', 'watch-me-too']
      tubes.watched.should == [tubes.find('default')]
      tubes.watch!(*tube_names)
      tubes.watched.should == [tubes.find(tube_names.first), tubes.find(tube_names.last)]
    end
  end

  describe "#use" do
    it "should set used to first or created tube with name:tube_name" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_name = 'use-this-tube'
      tubes.used.name.should == 'default'
      tubes.use(tube_name)
      tubes.used.name.should == tube_name
    end
  end

  describe "#first_or_create" do
    it "should return first known tube with tube_name if exists" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_name = 'default'
      tubes.first_or_create(tube_name).should == tubes.all.first
    end
    it "should create tube with name:tube_name if not known" do
      tubes = MockBeaneater::Tubes.new(double)
      tube_name = 'new-tube'
      tubes.all.map(&:name).include?(tube_name).should be_false
      tubes.first_or_create(tube_name).should == tubes.all.last
      tubes.all.map(&:name).include?(tube_name).should be_true
    end
  end
end
