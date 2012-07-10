class Hash

  def except_blank!
    # Remove empty values
    values.each{|h| h.except_blank! if h.is_a?(Hash)}
    # Remove empty inside array
    values.select{|v| v.is_a?(Array)}.flatten.each{|h| h.except_blank! if h.is_a?(Hash)}
    delete_if { |k, v| v.blank? }
    self
  end

  def except_blank
    self.dup.except_blank!
  end

  def widdle(*symbols)
    result = self
    symbols.each { |s| result = result[s] rescue nil }
    result
  end

  def symbolize_all_keys!
    symbolize_keys!
    # Symbolize each hash in values
    values.each{|h| h.symbolize_all_keys! if h.is_a?(Hash)}
    # Symbolize each hash inside array
    values.select{|v| v.is_a?(Array)}.flatten.each{|h| h.symbolize_all_keys! if h.is_a?(Hash)}
    self
  end

  def symbolize_all_keys
    self.dup.symbolize_all_keys!
  end

  def stringify_all_keys!
    stringify_keys!
    # Symbolize each hash in values
    values.each{|h| h.stringify_all_keys! if h.is_a?(Hash)}
    # Symbolize each hash inside array
    values.select{|v| v.is_a?(Array)}.flatten.each{|h| h.stringify_all_keys! if h.is_a?(Hash)}
    self
  end

  def stringify_all_keys
    self.dup.stringify_all_keys!
  end
end
