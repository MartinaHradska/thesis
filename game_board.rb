require './game_board_generator'
require './custom_condition'
class GameBoard
  attr_accessor :name, :width, :height, :is_2d, :board, :tile_values, :pieces,
                :legal_conditions, :update_mark_outside_conditions, :update_marked_conditions
  def initialize(name, width, height = 0, board = nil, tile_values = ['blank'], pieces=['empty'])
    @name = name
    @width = width
    @height = height
    @is_2d = height == 0 ? false : true
    @tile_values = tile_values
    @pieces = pieces
    if board == nil
      if @is_2d
        @board = Array.new(width, Array.new(height, Tile.new))
      else
        @board = Array.new(width, Tile.new)
      end
    else
      @board = board
    end
    @legal_conditions = []
    @update_mark_outside_conditions = []
    @update_marked_conditions = []
  end
  def set_all_tile_values(*values)
    if @is_2d
      @board.each {|row| row.each {|tile| tile.tile_values = values } }
    else
      @board.each {|tile| tile.tile_values = values }
    end
  end
  def set_all_piece_values(*pieces)
    if @is_2d
      @board.each {|row| row.each { |tile| tile.pieces = pieces }}
    else
      @board.each {|tile| tile.pieces = pieces }
    end
  end
  def has_tile_values?
    @tile_values != ['blank']
  end
  def has_pieces?
    @pieces != ['empty']
  end
  def create_json_template
    json = {}
    json[:name] = @name
    json[:width] = @width
    json[:height] = @height
    json[:is_2d] = @is_2d
    json[:board] = []
    @board.each do |row|
      tiles = []
      row.each{ |tile| tiles << tile.create_json_template }
      json[:board] << tiles
    end
    json[:tile_values] = @tile_values
    json[:pieces] = @pieces
    json[:legal_conditions] = @legal_conditions.map { |cond_array| cond_array.conditions.map { |cond| Relation.deserialize(cond) } }
    json[:update_mark_outside_conditions] = @update_mark_outside_conditions.map do |cond_array|
      conds = {}
      conds[:value] = cond_array.value
      conds[:conditions] = cond_array.conditions.map { |cond| Relation.deserialize(cond) }
      conds
    end
    json[:update_marked_conditions] = @update_marked_conditions.map do |cond_array|
      conds = {}
      conds[:value] = cond_array.value
      conds[:conditions] = cond_array.conditions.map { |cond| Relation.deserialize(cond) }
      conds
    end
    json
  end
  def self.load_from_json(json)
    if json[:is_2d]
      board = Array.new(json[:width],Array.new(json[:height]))
      json[:board].each_with_index { |row,x| row.each_with_index { |tile,y| board[x][y] = Tile.load_from_json(tile) } }
    else
      board = Array.new(json[:width])
      json[:board].each_with_index { |tile,x| board[x] = Tile.load_from_json(tile) }
    end
    board = GameBoard.new(json[:name], json[:width], json[:height], board, json[:tile_values], json[:pieces])
    board.legal_conditions = json[:legal_conditions].map { |rule| CustomCondition.new(nil, *(rule.map { |cond| Relation.serialize(cond) })) }
    board.update_mark_outside_conditions = json[:update_mark_outside_conditions]
                                               .map { |conds| CustomCondition.new(conds[:value], *(conds[:conditions].map { |cond| Relation.serialize(cond) })) }
    board.update_marked_conditions = json[:update_marked_conditions]
                                         .map { |conds| CustomCondition.new(conds[:value], *(conds[:conditions].map { |cond| Relation.serialize(cond) })) }
    board
  end
  include GameBoardGenerator
end