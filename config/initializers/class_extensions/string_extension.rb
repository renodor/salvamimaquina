# frozen_string_literal:true

class String
  def capitalize_second_letter # TODO: must be a simpler way to do that...
    words = split
    letters = words[0].chars
    letters[1] = letters[1].upcase
    words.map(&:capitalize!)
    words[0] = letters.join
    words.join(' ')
  end
end
