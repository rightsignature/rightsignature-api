module RefineHashToIndifferentAccess

  # Turn all hashes into "with indifferent access" hashes
  refine Hash do
    regular_indexing = instance_method(:[])
    define_method(:[]) do |key|
      if has_key? key.to_sym
        regular_indexing.bind(self).(key.to_sym)
      else
        regular_indexing.bind(self).(key.to_s)
      end
    end

    regular_deletion = instance_method(:delete)
    define_method(:delete) do |key|
      if has_key? key.to_sym
        regular_deletion.bind(self).(key.to_sym)
      else
        regular_deletion.bind(self).(key.to_s)
      end
    end
  end
end
