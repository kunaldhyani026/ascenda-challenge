module ApplicationHelper
  def strip_or_empty(str)
    str.present? ? str.to_s.strip : ''
  end

  def delete_space(str)
    str.gsub(' ', '')
  end

  def clean_array(arr)
    return [] unless arr.present?

    arr.map { |str| delete_space(str) } # Remove all whitespaces
       .reject(&:empty?) # Remove empty strings
       .compact # Remove nil values
  end
end
