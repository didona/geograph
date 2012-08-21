class Array
  def to_dml_json
    #map(&:attributes_to_hash).to_json
    map do |elem|
      if elem
        elem.attributes_to_hash
      end
    end.to_json
  end
end