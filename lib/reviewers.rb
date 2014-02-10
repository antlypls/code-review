require 'reviewers/reviewer'

module Reviewers
  class << self
    include Enumerable

    def each(&block)
      @reviewers.each(&block)
    end

    # Find reviewers eligible to review the given e-mail address.
    #
    # email - A String describing an e-mail address.
    #
    # Returns an Array of Reviewer instances.
    def for(email, langs = nil)
      select do |reviewer|
        reviewer.can_review?(email, langs)
      end
    end

    # Load reviewers.
    #
    # reviewers - A String describing a comma- and colon-separated list of
    #             reviewers (see the documentation for details).
    def load(reviewers)
      @reviewers = reviewers.split(",").map do |reviewer|
        Reviewer.parse(reviewer)
      end
    end
  end
end
