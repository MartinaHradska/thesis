require './player_generator'
class Player
  attr_accessor :name, :rounds
  def initialize(name, *rounds)
    @name = name
    @rounds = rounds
  end
  #Creates template for JSON
  def create_json_template
    json = {}
    json[:name] = @name
    json[:rounds] = @rounds
    json
  end
  #Creates new Player object from parsed JSON
  def self.load_from_json(json)
    self.new(json[:name], *json[:rounds])
  end
  include PlayerGenerator
end