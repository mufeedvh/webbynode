# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Rails do
  let(:io) { double("io").as_null_object }

  subject do
    Webbynode::Engines::Rails.new.tap do |engine|
      engine.stub!(:io).and_return(io)
    end
  end
  
  describe 'class methods' do
    subject { Webbynode::Engines::Rails }

    its(:engine_id)    { should == 'rails' }
    its(:engine_name)  { should == 'Rails 2' }
    its(:git_excluded) { should == ["config/database.yml"] } #, "db/schema.rb"] }
  end
  
  describe '#detect' do
    it "returns true if app app/controllers and config/environent.rb are found" do
      io.stub!(:directory?).with('app').and_return(true)
      io.stub!(:directory?).with('app/controllers').and_return(true)
      io.stub!(:file_exists?).with('config/environment.rb').and_return(true)
      
      subject.should be_detected
    end

    it "returns false if any isn't found" do
      io.stub!(:directory?).with('app').and_return(true)
      io.stub!(:directory?).with('app/controllers').and_return(false)
      io.stub!(:file_exists?).with('config/environent.rb').and_return(true)
      
      subject.should_not be_detected
    end
  end
  
  describe '#prepare' do
    it "adds a rails_adapter setting when mysql2 is used on the database.yml" do
      io.should_receive(:file_exists?).with("config/database.yml").and_return(true)
      io.should_receive(:read_file).with("config/database.yml").and_return("mysql2")
      io.should_receive(:add_setting).with('rails_adapter', 'mysql2')

      subject.prepare
    end
    
    it "doesn't add a rails_adapter otherwise" do
      io.should_receive(:file_exists?).with("config/database.yml").and_return(true)
      io.should_receive(:read_file).with("config/database.yml").and_return("mysql")
      io.should_receive(:add_setting).with('rails_adapter', 'mysql2').never
      io.should_receive(:remove_setting).with('rails_adapter')

      subject.prepare
    end

    it "doesn't add a rails_adapter if missing config/database.yml" do
      io.should_receive(:file_exists?).with("config/database.yml").and_return(false)
      io.should_receive(:read_file).with("config/database.yml").never
      io.should_receive(:add_setting).with('rails_adapter', 'mysql2').never
      io.should_receive(:remove_setting).with('rails_adapter')

      subject.prepare
    end    
  end
end
