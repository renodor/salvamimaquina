# frozen_string_literal:true

class String
  def capitalize_second_letter
    letters = chars
    letters[1] = letters[1].upcase
    letters.join
  end
end
