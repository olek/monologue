require 'spec_helper'

describe Monologue::TagRecord do
  before(:each) do
    @tag= FactoryGirl.create(:tag)
  end

  it "is valid with valid attributes" do
    @tag.should be_valid
  end

  describe "validations" do
    it "is not possible to have save another tag with the same name" do
       expect { FactoryGirl.create(:tag) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should require the name to be set" do
      expect { FactoryGirl.create(:tag,name:nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
