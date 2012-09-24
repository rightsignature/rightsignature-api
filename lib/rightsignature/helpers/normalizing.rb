module RightSignature::Helpers
  module TagsHelper
    class <<self
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
            {:tag => {:name => name, :value => value}}
          else
            {:tag => {:name => t}}
          end
        end
      end
      
    end
  end
  
  module RolesHelper
    class <<self
      # Converts [{"Role Name" => {:name => "John", :email => "email@example.com"}}] to 
      #   [{:role => {:name => "John", :email => "email@example.com", "@role_name" => "Role Name"} }]
      def array_to_xml_hash(roles_array)
        roles_hash_array = []
        roles_array.each do |role_hash|
          name, value = role_hash.first
          raise "Hash '#{role_hash.inspect}' is malformed, should be something like {ROLE_NAME => {:name => \"a\", :email => \"a@a.com\"}}" unless value.is_a? Hash and name.is_a? String
          roles_hash_array << {:role => value.merge({"@role_name" => name})}
        end
      
        roles_hash_array
      end

    end
  end

  
  module MergeFieldsHelper
    class <<self
      # Converts [{"Role Name" => {:name => "John", :email => "email@example.com"}}] to 
      #   [{"role roles_name=\"Role Name\"" => {:role => {:name => "John", :email => "email@example.com"}} }]
      def array_to_xml_hash(merge_fields_array)
        merge_fields = []
        merge_fields_array.each do |merge_field_hash|
          name, value = merge_field_hash.first
          merge_fields << { :merge_field => {:value => value, "@merge_field_name" => name}}
        end

        merge_fields
      end

    end
  end
  
  def array_to_acceptable_names_hash(acceptable_names)
    converted_fields = []
    acceptable_names.each do |name|
      converted_fields << {:name => name}
    end
    
    converted_fields
  end
end