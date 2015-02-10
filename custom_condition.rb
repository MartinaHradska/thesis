class CustomCondition
  attr_accessor :value, :conditions
  def initialize(value = nil, *conditions)
    @value = value
    @conditions = conditions == nil ? [] : conditions
  end
end