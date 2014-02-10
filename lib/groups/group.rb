module Groups
  # Group
  # name      - a string describing group name
  # languages - array of string, describing languages
  #             available for this group for review
  class Group < Struct.new(:name, :languages)
    def self.parse(group)
      name, langs = group.split(':')
      languages = langs.split(',')
      new(name, languages)
    end

    # checks if group has specified language
    def language?(lang)
      languages.include?(lang)
    end
  end
end
