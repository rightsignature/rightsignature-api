module RightSignature
  module Helpers
    module Tags
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
end