class Relation
  attr_accessor :name, :arguments, :negation

  def initialize(name, *arguments)
    @name = name
    if arguments[-1].is_a?(TrueClass) || arguments[-1].is_a?(FalseClass)
      @negation = arguments[-1]
      @arguments = arguments[0 .. -2]
    else
      @negation = false
      @arguments = arguments
    end
  end
  #Creates objects from simple rules
  def self.serialize(rule_string)
    if rule_string[0] == '~'
      negation = true
      rule_string = rule_string[2 .. -1]
    else
      negation = false
    end
    if !Relation.constant_or_variable?(rule_string)
      #Used to split Relation by commas without spliting nested Relations
      pattern = Regexp.new('((?>[^,(]++|(\((?>[^()]++|\g<-1>)*\)))+)')
      divider_index = rule_string.index('(')
      name = rule_string[0 .. (divider_index - 1)]
      arguments = rule_string[(divider_index + 1) .. -2].scan(pattern).map { |arg| Relation.serialize(arg.first) }
      self.new(name, *arguments, negation)
    else
      rule_string[0] =~ /[a-zA-Z]/ && rule_string[0] == rule_string[0].upcase ? "?#{rule_string.downcase}" : rule_string
    end
  end
  #Creates objects from simple rules in prefix syntax
  def self.serialize_prefix(rule_string)
    if !Relation.constant_or_variable?(rule_string)
      rule_string = rule_string[1 .. -2]
      if rule_string[0 .. 2] == 'not'
        negation = true
        rule_string = rule_string[5 .. -2]
      else
        negation = false
      end
      #Used to split Relation by spaces without spliting nested Relations
      pattern = Regexp.new('((?>[^\s(]++|(\((?>[^()]++|\g<-1>)*\)))+)')
      divider_index = rule_string.index(' ')
      name = rule_string[0 .. (divider_index - 1)]
      arguments = rule_string[(divider_index + 1) .. -1].scan(pattern).map { |arg| Relation.serialize_prefix(arg.first) }
      self.new(name, *arguments, negation)
    else
      rule_string
    end
  end
  #Creates simple rules from objects
  def self.deserialize(rel)
    if rel.is_a?(Relation)
      "#{'~' if rel.negation}#{rel.name}(#{rel.arguments.map{ |arg| Relation.deserialize(arg) }.join(',')})"
    else
      if rel[0] == '?'
        new_rel = rel[1 .. -1]
        new_rel[0] = new_rel[0].upcase
      else
        new_rel = rel
      end
      new_rel
    end
  end
  #Creates simple rules in prefix syntax from objects
  def self.deserialize_to_prefix(rel)
    if rel.is_a?(Relation)
      "(#{'not ' if rel.negation}#{rel.name} #{rel.arguments.map{ |arg| Relation.deserialize_to_prefix(arg) }.join(' ')})"
    else
      rel
    end
  end
  #Returns true if param is not composed of more simple rules
  def self.constant_or_variable?(param)
    !param.include?('(') && !param.include?(')') && !param.include?(' ')
  end
  def eql?(o)
    @name == o.name && @args == o.args
  end
  def ==(o)
    eql?(o)
  end
  def hash
    @name.hash ^ @args.hash
  end
end