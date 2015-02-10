require './relation'
class Rule
  attr_accessor :head, :body
  def initialize(head, *body)
    @head = head
    @body = body
  end
  #Creates objects from composed rules
  def self.serialize(rule_string)
    if self.composed?(rule_string)
      rule = rule_string.split(':-').map { |arg| arg.strip }
      head = Relation.serialize(rule[0])
      body = rule[1].split('&').map { |arg| Relation.serialize(arg.strip) }
      self.new(head, *body)
    else
      self.new(Relation.serialize(rule_string), nil)
    end
  end
  #Creates objects from composed rules in prefix syntax
  def self.serialize_prefix(rule_string)
    if self.composed?(rule_string)
      rule_string = rule_string[1 .. -2]
      #Used to split Rules by spaces without spliting nested Rules
      pattern = Regexp.new('((?>[^\s(]++|(\((?>[^()]++|\g<-1>)*\)))+)')
      stop = rule_string.index(')')
      head = Relation.serialize_prefix(rule_string[rule_string.index('(') .. stop])
      rule_string = rule_string[stop + 1 .. -1]
      rule_string = rule_string[rule_string.index('and') + 3 .. -2] if rule_string.include?('and')
      body = rule_string.scan(pattern).map { |arg| Relation.serialize_prefix(arg.first) }
      self.new(head, *body)
    else
      self.new(Relation.serialize(rule_string),nil)
    end
  end
  #Creates composed rules from objects
  def self.deserialize(rule)
    if rule.is_a?(Rule)
      "#{Relation.deserialize(rule.head)} :- #{rule.body.map { |r| Relation.deserialize(r) }.join(' & ')}"
    else
      Relation.deserialize(rule)
    end
  end
  #Creates composed rules in prefix syntax from objects
  def self.deserialize_to_prefix(rule)
    if rule.is_a?(Rule)
      "(<= #{Relation.deserialize_to_prefix(rule.head)} #{rule.body.map { |rel| Relation.deserialize_to_prefix(rel) }.join(' ')})"
    else
      Relation.deserialize_to_prefix(rule)
    end
  end
  def eql?(o)
    @head == o.head && @body == body
  end
  def ==(o)
    eql?(o)
  end
  def hash
    @head.hash ^ @body.hash
  end
  def self.composed?(string)
    string.include?(':-') || string.include?('<=')
  end
end