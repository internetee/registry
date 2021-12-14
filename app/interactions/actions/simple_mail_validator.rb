module Actions
  module SimpleMailValidator
    extend self

    def run(email:, level:)
      Truemail.validate(email, with: level).result
    end
  end
end
