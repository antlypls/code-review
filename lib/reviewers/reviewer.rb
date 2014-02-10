module Reviewers
  # Reviewer.
  #
  # email   - A String describing the reviewer's primary e-mail address.
  # aliases - An Array of Strings describing the reviewer's
  #           secondary e-mail addresses (if any).
  # group   - A string describing reviewer's group.
  class Reviewer < Struct.new(:email, :aliases, :group)
    # Returns an Array of Strings describing the reviewer's e-mail addresses.
    def emails
      [email] + Array(aliases)
    end

    def self.parse(reviewer)
      addresses, group = reviewer.split('|')
      addresses = addresses.split(':')
      new(addresses[0], addresses[1..-1], group)
    end

    def can_review?(email, langs = nil)
      emails.exclude?(email) && understands_any_language?(langs)
    end

    def understands_any_language?(langs)
      return true if skip_langs_check?(langs)
      Array(langs).any? { |lang| understands_language?(lang) }
    end

    def understands_language?(lang)
      return true if skip_langs_check?(lang)
      actual_group.language?(lang) if actual_group
    end

    private

    # reviewer can review code if no groups provided
    # or lang/langs are not specified (nil or empty)
    def skip_langs_check?(langs)
      langs.blank? || actual_group.blank?
    end

    def actual_group
      return nil if group.blank?
      Groups.find_by_name(group)
    end
  end
end
