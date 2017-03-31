module RefineHashToIndifferentAccess

  # Turn all hashes into "with indifferent access" hashes
  refine Hash do
    regular_indexing = instance_method(:[])
    define_method(:[]) do |key|
      if has_key? key.to_s
        regular_indexing.bind(self).(key.to_s)
      else
        regular_indexing.bind(self).(key.to_sym)
      end
    end

    regular_assignment = instance_method(:[]=)
    define_method(:[]=) do |key, value|
      if has_key? key.to_s
        regular_assignment.bind(self).(key.to_s, value)
      else
        regular_assignment.bind(self).(key.to_sym, value)
      end
    end

    regular_deletion = instance_method(:delete)
    define_method(:delete) do |key|
      if has_key? key.to_s
        regular_deletion.bind(self).(key.to_s)
      else
        regular_deletion.bind(self).(key.to_sym)
      end
    end
  end
end
