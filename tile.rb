class Tile
  attr_accessor :tile_values, :pieces
  def initialize(tile_values = ['blank'], pieces = ['empty'])
    @tile_values = tile_values
    @pieces = pieces
  end
  def create_json_template
    json = {}
    json[:tile_values] = @tile_values
    json[:pieces] = @pieces
    json
  end
  def self.load_from_json(json)
    self.new(json[:tile_values], json[:pieces])
  end
end