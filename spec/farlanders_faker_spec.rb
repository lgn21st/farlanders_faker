require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe FarlandersFaker do
  before(:each) do
    Object.instance_eval do
      module I18n
        class << self
          def locale
            :en
          end
        end
      end
    end
  end
  
  describe "locale without rails" do
    before(:each) do
      Object.send(:remove_const, :I18n) if defined?(I18n)
    end
    
    it "should have default locale" do
      FarlandersFaker.locale.should == :en
    end
    
    it "can sets the current locale" do
      FarlandersFaker.locale = :new_locale
      FarlandersFaker.locale.should == :new_locale
      
    end
  end
  
  describe "locale with rails I18n support" do
    after(:each) do
      FarlandersFaker.locale = :en
    end
    
    it "should reading locale from rails I18n support" do
      I18n.should_receive(:locale).and_return :locale_from_rails_I18n
      FarlandersFaker.locale.should == :locale_from_rails_I18n
    end
    
    it "do not override rails' locale setting" do
      I18n.should_receive(:locale).and_return :locale_from_rails_I18n
      FarlandersFaker.locale = :reset_locale
      FarlandersFaker.locale.should == :locale_from_rails_I18n
    end
  end
  
  describe "generate names by name faker" do
    it "should delegate name to name fakder with current locale" do
      FarlandersFaker.should_receive(:locale).and_return(:current_locale)
      FarlandersFaker.name_faker.should_receive(:name).with(:current_locale)
      FarlandersFaker.name
    end
  end
  
  describe "name faker" do
    it "should respond to name_faker" do
      FarlandersFaker.should be_respond_to(:name_faker)
    end
    
    it "should instantiated FarlandersFaker::Name" do
      FarlandersFaker.name_faker.should be_is_a(FarlandersFaker::Name)
    end
    
    it "can store names template" do
      faker = FarlandersFaker::Name.new
      name_sets = {:first_name => %w(Daniel), :last_name => %w(Lv)}
      faker.merge_names :en, name_sets
      faker.names.should == {:en => name_sets}
    end
    
    describe FarlandersFaker::Name do
      before(:each) do
        @faker = FarlandersFaker::Name.new
        @faker.stub!(:init_names?).and_return(true)
        @faker.merge_names :en, {:first_name => %w(Daniel), :last_name => %w(Lv)}
      end
      
      it "should have available locales" do
        @faker.available_locales.should == [:en]
      end
      
      it "should have default locales" do
        FarlandersFaker.should_receive(:default_locale).and_return(:en)
        @faker.default_locale.should == :en
      end
      
      it "should generate name with default locale" do
        @faker.name(:en).should == "Daniel Lv"
      end
      
      it "will using default locale if special locale was not exists" do
        @faker.name(:zh).should == "Daniel Lv"
      end
      
      it "can add more locale support" do
        @faker.merge_names :zh, {:first_name => %(Rick), :last_name => 'Hu'}
        @faker.name(:zh).should == "Rick Hu"
      end
    end
  end
end
