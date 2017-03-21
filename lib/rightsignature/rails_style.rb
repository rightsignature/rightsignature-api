using RefineHashToIndifferentAccess

module RightSignature
  class RailsStyle < Connection
    def prepackage_and_send guid, roles, options
      # These conversions are basically from Rails-style structures to XML-style structures

      # Convert hashes to array-of-hashes
      # {k1: v1, k2: v2} => [{k1: v1}, {k2: v2}]

      options[:merge_fields] = (options.delete(:merge_fields)||{}).collect{|k,v| {k => v}}

      roles = roles.collect{|k,v| {k => v}}

      options[:tags] =
        (options[:tags]||[]) +
        (options.delete(:metadata)||{}).collect{|k,v| {k => v} if v && ! v.to_s.strip.empty?}.select{|h| ! h.nil?}

      # TODO: Resolve RS choking on anything a HashWithIndifferentAccess
      super guid, roles, options
    end

    #TODO: Copy pasta
    def template_details guid
      doc = super(guid)[:template]

      tags_string = doc.delete(:tags)
      doc[:metadata] = TagsHelper.metadata_hash_from_tags_string tags_string
      doc[:tags] = TagsHelper.tags_array_from_tags_string tags_string

      # Convert a deeply nested array of objects into a normal hash
      # Note: Must check if it's a deeply nested hash instead, since that is what occurs
      #  for single-item XLM "arrays"
      # {..., recipients: {recipient: [{...},{...}]}} => {..., recipients: {...: {...}, ...:{...}}}
      tmp = doc[:roles][:role].is_a?(Hash) ? [doc[:roles][:role]] : doc[:roles][:role]
      doc[:roles] = tmp.reduce({}){|h, v| h[v[:document_role_id]] = v and h}

      tmp = doc[:merge_fields][:merge_field].is_a?(Hash) ? [doc[:merge_fields][:merge_field]] : doc[:merge_fields][:merge_field]
      doc[:merge_fields] = tmp.reduce({}){|h, v| h[v[:name]] = v and h}

      # Extract a few fields from a deeply nested array
      tmp = doc[:pages][:page].is_a?(Hash) ? doc[:pages][:page] : doc[:pages][:page].first
      %i(original_template_guid original_template_filename).each do |sym|
        doc[sym] = tmp[sym]
      end
      doc.delete(:pages)

      %i(thumbnail_url).each do |sym|
        doc[sym] = CGI.unescape doc[sym]
      end

      doc
    end

    def document_details guid
      doc = super(guid)[:document]

      tags_string = doc.delete(:tags)
      doc[:metadata] = TagsHelper.metadata_hash_from_tags_string tags_string
      doc[:tags] = TagsHelper.tags_array_from_tags_string tags_string

      # Convert a deeply nested array of objects into a normal hash
      # Note: Must check if it's a deeply nested hash instead, since that is what occurs
      #  for single-item XLM "arrays"
      # {..., recipients: {recipient: [{...},{...}]}} => {..., recipients: {...: {...}, ...:{...}}}
      tmp = doc[:recipients][:recipient].is_a?(Hash) ? [doc[:recipients][:recipient]] : doc[:recipients][:recipient]
      doc[:recipients] = tmp.reduce({}){|h, v| h[v[:role_id]] = v and h}

      tmp = doc[:audit_trails][:audit_trail].is_a?(Hash) ? [doc[:audit_trails][:audit_trail]] : doc[:audit_trails][:audit_trail]
      doc[:audit_trails] = tmp.reduce({}){|h, v| h[v[:timestamp]] = v and h}

      tmp = doc[:form_fields][:form_field].is_a?(Hash) ? [doc[:form_fields][:form_field]] : doc[:form_fields][:form_field]
      doc[:form_fields] = tmp.reduce({}){|h, v| h[v[:name]] = v and h}

      # Extract a few fields from a deeply nested array
      tmp = doc[:pages][:page].is_a?(Hash) ? doc[:pages][:page] : doc[:pages][:page].first
      %i(original_template_guid original_template_filename).each do |sym|
        doc[sym] = tmp[sym]
      end
      doc.delete(:pages)

      %i(original_url pdf_url thumbnail_url large_url signed_pdf_url).each do |sym|
        doc[sym] = CGI.unescape doc[sym]
      end

      doc
    end
  end
end
