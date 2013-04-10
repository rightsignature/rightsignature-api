module RightSignature::Helpers #:nodoc:
  module TagsHelper #:nodoc: 
    class <<self #:nodoc: 
      def mixed_array_to_string_array(array_of_tags)
        return array_of_tags unless array_of_tags.is_a?(Array)
  
        tags = []
        array_of_tags.each_with_index do |tag, idx|
          if tag.is_a? Hash
            tags << tag.first.join(':')
          elsif tag.is_a? String
            tags << tag
          else
            raise "Tags should be an array of Strings ('tag_name') or Hashes ({'tag_name' => 'value'})"
          end
        end
  
        tags.join(',')
      end
  
      def array_to_xml_hash(tags_array)
        tags_array.map do |t|
          if t.is_a? Hash
            name, value = t.first
            {:tag => {:name => name.to_s, :value => value.to_s}}
          else
            {:tag => {:name => t.to_s}}
          end
        end
      end
      
    end
  end
  
  module RolesHelper #:nodoc: 
    class <<self #:nodoc: 
      # Converts [{"Role_ID" => {:name => "John", :email => "email@example.com"}}] to 
      #   [{:role => {:name => "John", :email => "email@example.com", "@role_id" => "Role_ID"} }]
      # Tries to guess if it's using Role ID or Role Name
      def array_to_xml_hash(roles_array)
        roles_hash_array = []
        roles_array.each do |role_hash|
          name, value = role_hash.first
          raise "Hash '#{role_hash.inspect}' is malformed, should be something like {ROLE_NAME => {:name => \"a\", :email => \"a@a.com\"}}" unless value.is_a? Hash and name.is_a? String
          if name.match(/^signer_[A-Z]+$/) || name.match(/^cc_[A-Z]+$/)
            roles_hash_array << {:role => value.merge({"@role_id" => name.to_s})}
          else
            roles_hash_array << {:role => value.merge({"@role_name" => name.to_s})}
          end
        end
      
        roles_hash_array
      end

    end
  end

  
  module MergeFieldsHelper #:nodoc: 
    class <<self #:nodoc:
      # Converts [{"Role Name" => {:name => "John", :email => "email@example.com"}}] to 
      #   [{"role roles_name=\"Role Name\"" => {:role => {:name => "John", :email => "email@example.com"}} }]
      def array_to_xml_hash(merge_fields_array, use_id=false)
        merge_fields = []
        merge_fields_array.each do |merge_field_hash|
          name, value = merge_field_hash.first
          if use_id
            merge_fields << { :merge_field => {:value => value.to_s, "@merge_field_id" => name.to_s}}
          else
            merge_fields << { :merge_field => {:value => value.to_s, "@merge_field_name" => name.to_s}}
          end
        end

        merge_fields
      end

    end
  end
  
   #:nodoc: 
  def array_to_acceptable_names_hash(acceptable_names)
    converted_fields = []
    acceptable_names.each do |name|
      converted_fields << {:name => name}
    end
    
    converted_fields
  end
end