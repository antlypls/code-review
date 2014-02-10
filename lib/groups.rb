require 'groups/group'

module Groups
  class << self
    include Enumerable

    def each(&block)
      @groups.each(&block)
    end

    def load(groups)
      groups ||= ''
      @groups = groups.split(';').map { |group| Group.parse(group) }
    end

    def find_by_name(group_name)
      @groups.find { |g| g.name == group_name }
    end
  end
end
