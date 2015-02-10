require 'rubygems'
require 'json'
require './game_board'
require './player'
#require './stack'
require './relation'
require './rule'

class Game
  attr_accessor :name, :players, :boards, :stacks, :round_players, :rules
  @@rounds = 0
  def initialize(name, rounds, players = {}, boards = {}, stacks = {}, round_players = [])
    @name = name
    @@rounds = rounds
    @players = players
    @boards = boards
    @stacks = stacks
    @round_players = round_players
    @rules = []
  end
  def self.load_from_file(file)
    json = JSON.parse(File.read("#{file}.json"), { :symbolize_names => true })
    players = {}
    json[:players].each { |player| players[player[:name]] = Player.load_from_json(player) }
    boards = {}
    json[:boards].each { |board| boards[board[:name]] = GameBoard.load_from_json(board)}
    stacks = {}
    json[:stacks].each { |stack| stacks[stack[:name]] = Stack.load_from_json(stack)}
    round_players = json[:round_players]
    Game.new(json[:name],json[:rounds].to_i, players, boards, stacks, round_players)
  end
  def self.delete(file)
    File.delete(file)
  end
  def generate_rules
    players.each_value { |player| @rules += player.generate_player }
    @rules += generate_rounds
    @rules += @boards.first[1].generate_board
  end
  def generate_legal_rule(*condition_ids)
    @rules += @boards.first[1].generate_legal_board(*condition_ids)
  end
  def generate_update_rules

  end
  def save_to_file
    File.open("#{name}.json", 'w') {|file| file.write(to_json)}
  end
  def generate_rounds
    generate_base_for_rounds + generate_init_for_rounds + generate_update_for_rounds + generate_round_sequence
  end
  def generate_base_for_rounds
    base = []
    round = 1
    @@rounds.times do
      base << Relation.new("base", Relation.new("round", round))
      round = round + 1
    end
    base
  end
  def generate_init_for_rounds
    [Relation.new("init", Relation.new("round","1"))]
  end

  def generate_update_for_rounds
    [Rule.new(Relation.new("next", Relation.new("round","X")), Relation.new("true", Relation.new("round", "Y")), Relation.new("previous_round", "Y","X"))]
  end
  def generate_round_sequence
    round = 1
    sequence = []
    @@rounds.times do
      if round == 1
        sequence << Relation.new("previous_round", @@rounds, round)
      else
        sequence << Relation.new("previous_round", round - 1, round)
      end
      round += 1
    end
    sequence
  end
  def create_json_template
    json = {}
    json[:name] = @name
    json[:rounds] = @@rounds
    json[:players] = []
    @players.each_value { |player| json[:players] << player.create_json_template }
    json[:boards] = []
    @boards.each_value { |board| json[:boards] << board.create_json_template }
    json[:stacks] = []
    @stacks.each_value { |stack| json[:stacks] << stack.create_json_template }
    json[:round_players] = @round_players
    json
  end
  def to_json
    JSON.pretty_generate(create_json_template)
  end
  def self.rounds
    @@rounds
  end
  def self.rounds=(val)
    @@rounds = val
  end
end