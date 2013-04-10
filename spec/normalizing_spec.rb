require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::Helpers::TagsHelper do 
  describe "mixed_array_to_string_array" do
    it "should convert array of strings and hashes to string" do
      RightSignature::Helpers::TagsHelper.mixed_array_to_string_array(["a", {'good' => "yea"}, '123']).should == "a,good:yea,123"
    end
    
    it "should raise error if array contains something other than hash or string" do
      lambda {RightSignature::Helpers::TagsHelper.mixed_array_to_string_array(["a", ['bad'], {'good' => "yea"}])}.should raise_error
    end
  end
  
  describe "array_to_xml_hash" do
    it "should convert array of string and hash of {name => value} into array of :tag => {:name => name, :value => value}" do
      RightSignature::Helpers::TagsHelper.array_to_xml_hash(['abc', {"taggy" => "tvalue"}]).should == [{:tag => {:name => 'abc'}}, {:tag => {:name => 'taggy', :value => 'tvalue'}}]
    end
    
    it "should convert a symbol to a string for names and values" do
      RightSignature::Helpers::TagsHelper.array_to_xml_hash([:abc, {:taggy => :tvalue}]).should == [
        {:tag => {:name => 'abc'}}, 
        {:tag => {:name => 'taggy', :value => 'tvalue'}}
      ]
    end
  end
end

describe RightSignature::Helpers::RolesHelper do
  describe "array_to_xml_hash" do
    it "should convert array of {\"Role name\" => {:name => name, :email => email}} to array of {:role => {:name => name, :email => email, \"@role_id\" => \"Role name\"}} " do
      results = RightSignature::Helpers::RolesHelper.array_to_xml_hash([
        {"Leaser" => {:name => "John Bellingham", :email => "j@example.com"}}, 
        {"Leasee" => {:name => "Timmy S", :email => "t@example.com"}}
      ])
      results.size.should == 2
      results.include?({:role => {:name => "John Bellingham", :email => "j@example.com", "@role_name" => "Leaser"}})
      results.include?({:role => {:name => "Timmy S", :email => "t@example.com", "@role_name" => "Leasee"}})
    end

    it "should convert array of {\"signer_A\" => {:name => name, :email => email}} or {\"cc_A\" => {:name => name, :email => email}} to array of {:role => {:name => name, :email => email, \"@role_id\" => \"signer_a\"}} " do
      results = RightSignature::Helpers::RolesHelper.array_to_xml_hash([
        {"signer_A" => {:name => "John Bellingham", :email => "j@example.com"}}, 
        {"cc_A" => {:name => "Timmy S", :email => "t@example.com"}}
      ])
      results.size.should == 2
      results.include?({:role => {:name => "John Bellingham", :email => "j@example.com", "@role_id" => "signer_A"}})
      results.include?({:role => {:name => "Timmy S", :email => "t@example.com", "@role_id" => "cc_A"}})
    end
  end
end

describe RightSignature::Helpers::MergeFieldsHelper do
  describe "array_to_xml_hash" do
    it "should convert array of {\"Merge field name\" => \"Merge Field Value\"} to array of {:merge_field => {:value => \"Merge Field Value\", \"@merge_field_name\" => \"Merge Field Name\"}} " do
      results = RightSignature::Helpers::MergeFieldsHelper.array_to_xml_hash([
        {"City" => "Santa Barbara"},
        {"Section" => "House"}
      ])
      results.size.should == 2
      results.include?({:merge_field => {:value => "Santa Barbara", "@merge_field_name" => "City"}})
      results.include?({:merge_field => {:value => "House", "@merge_field_name" => "Section"}})
    end

    it "should convert array of {\"Merge field name\" => \"Merge Field Value\"} to array of {:merge_field => {:value => \"Merge Field Value\", \"@merge_field_id\" => \"Merge Field Name\"}} " do
      results = RightSignature::Helpers::MergeFieldsHelper.array_to_xml_hash([
        {"1_abc_defg" => "Santa Barbara"},
        {"2_345_789" => "House"}
      ], true)
      results.size.should == 2
      results.include?({:merge_field => {:value => "Santa Barbara", "@merge_field_id" => "1_abc_defg"}})
      results.include?({:merge_field => {:value => "House", "@merge_field_id" => "2_345_789"}})
    end
    
    it "should convert a symbol to a string for names and values" do
      results = RightSignature::Helpers::MergeFieldsHelper.array_to_xml_hash([
        {:abc_defg => :SomeValue},
        {:higjk => "House"}
      ], true)
      results.size.should == 2
      results.include?({:merge_field => {:value => "SomeValue", "@merge_field_id" => "abc_defg"}})
      results.include?({:merge_field => {:value => "House", "@merge_field_id" => "higjk"}})
    end

  end
end
