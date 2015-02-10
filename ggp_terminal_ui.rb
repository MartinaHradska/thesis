require 'highline'
require 'cli-console'
require './game'

class GGPTerminalUI
  private
  extend CLI::Task

  public

  def parse_arguments(params)
    arguments = {}
    params.each do |arg|
      split = arg.split('=')
      arguments[split[0].to_sym] = split[1]
    end
    arguments
  end

  def new(params)
    entity = params[0]
    argumnets = parse_arguments(params[1 .. -1])
    case entity
      when 'game'
        @game = Game.new(argumnets[:name], argumnets[:rounds].to_i)
      when 'player'
        @game.players[argumnets[:name]] = Player.new(argumnets[:name], argumnets[:round].to_i)
        if @game.round_players.include?(argumnets[:round].to_i - 1)
          @game.round_players[argumnets[:round].to_i - 1] << argumnets[:name]
        else
          @game.round_players[argumnets[:round].to_i - 1] = [argumnets[:name]]
        end
      when 'board'
        if argumnets.include?(:height)
          @game.boards[argumnets[:name]] = GameBoard.new(argumnets[:name], argumnets[:width].to_i, argumnets[:height].to_i)
        else
          @game.boards[argumnets[:name]] = GameBoard.new(argumnets[:name], argumnets[:width].to_i)
        end
      when 'stack'
        if argumnets.include?(:connect_board)
          if argumnets.include?(:connectY)
            @game.stacks[argumnets[:name]] = Stack.new(argumnets[:name], argumnets[:size].to_i, argumnets[:connect_board], argumnets[:connectX].to_i, argumnets[:connectY].to_i)
          else
            @game.stacks[argumnets[:name]] = Stack.new(argumnets[:name], argumnets[:size].to_i, argumnets[:connect_board], argumnets[:connectX].to_i)
          end
        else
          @game.stacks[argumnets[:name]] = Stack.new(argumnets[:name], argumnets[:size].to_i)
        end
    end
  end
  def load(params)
    entity = params[0]
    argumnets = parse_arguments(params[1 .. -1])
    case entity
      when 'game'
        @game = Game.load_from_file(argumnets[:file])
    end
  end
  def delete(params)
    entity = params[0]
    argumnets = parse_arguments(params[1 .. -1])
    case entity
      when 'game'
        Game.delete(argumnets[:file])
      when 'player'
        @game.players.delete(argumnets[:name])
      when 'board'
        @game.boards.delete[argumnets[:name]]
      when 'stack'
        @game.stacks.delete(argumnets[:name])
    end
  end
  def generate(params)
    entity = params[0]
    argumnets = parse_arguments(params[1 .. -1])
    case entity
      when 'basic'
        @game.generate_rules
      when 'legal'
        conds = argumnets[:conditions][1..-1].split(',').map { |cond| cond.strip }
        @game.generate_legal_rule(*conds)

    end
  end
  def save(params)
    @game.save_to_file if params.empty?
  end
  def update(params)
    entity = params[0]
    argumnets = parse_arguments(params[1 .. -1])
    case entity
      when 'player'
        name = argumnets.include?(:new_name) ? argumnets[:new_name] : argumnets[:name]
        round = argumnets.include?(:new_round) ? argumnets[:new_round] : argumnets[:name]
        @game.players.delete(argumnets[:name]) if argumnets[:name] != argumnets[:new_name]
        @game.players[argumnets[:new_name]] = Player.new(argumnets[name], argumnets[round])
      when 'board'
        @game.boards[argumnets[:name]].width = argumnets[:width] if argumnets.include?(:width)
        @game.boards[argumnets[:name]].height = argumnets[:height] if argumnets.include?(:height)
      when 'tile'
        if @game.boards[argumnets[:board_name]].is_2d
          @game.boards[argumnets[:board_name]].board[argumnets[:x]][argumnets[:y]].square_values = [argumnets[:val]] if argumnets.include?(:val)
          @game.boards[argumnets[:board_name]].board[argumnets[:x]][argumnets[:y]].pieces = [argumnets[:piece]] if argumnets.include?(:piece)
        else
          @game.boards[argumnets[:board_name]].board[argumnets[:x]].square_values = [argumnets[:val]] if argumnets.include?(:val)
          @game.boards[argumnets[:board_name]].board[argumnets[:x]].pieces = [argumnets[:piece]] if argumnets.include?(:piece)
        end
      when 'stack'
        @game.stacks[argumnets[:name]].connectX = argumnets[:connectX] if argumnets.include?(:connectX)
        @game.stacks[argumnets[:name]].connectX = argumnets[:connectY] if argumnets.include?(:connectY)
        @game.stacks[argumnets[:name]].add_piece(argumnets[:add_piece]) if argumnets.include?(:add_piece)
        @game.stacks[argumnets[:name]].delete_piece(argumnets[:del_piece]) if argumnets.include?(:del_piece)
    end
  end
  def show(params)
    entity = params[0]
    argumnets = parse_arguments(params[1 .. -1])
    case entity
      when 'game'
        puts "Game: \n name: #{ @game.name } \n rounds: #{ Game.rounds }"
      when 'player'
        puts "Player: \n name: #{ argumnets[:name] } \n rounds: #{ @game.players[argumnets[:name]].rounds.join(', ') }"
      when 'board'
        puts "Board: \n name: #{ argumnets[:name] } \n width: #{ @game.boards[argumnets[:name]].width } \n"
        if @game.boards[argumnets[:name]].is_2d
          puts " height: #{ @game.boards[argumnets[:name]].height } \n"
          @game.boards[argumnets[:name]].board.each_with_index { |row,x| row.each_with_index { |tile,y| puts " [#{ x }, #{ y }] - [#{ tile.square_values.join(',') }], [#{ tile.pieces.join(',') }]" } }
        else
          @game.boards[argumnets[:name]].board.each_with_index { |tile,x| puts " [#{ x }] - [#{ tile.square_values.join(',') }], [#{ tile.pieces.join(',') }]" }
        end
      when 'tile'
        if @game.boards[argumnets[:board_name]].is_2d
          puts "Board: #{ argumnets[:board_name] } \n #{ @game.boards[argumnets[:board_name]].board[argumnets[:x].to_i][argumnets[:y].to_i] }"
        else
          puts "Board: #{ argumnets[:board_name] } \n #{ @game.boards[argumnets[:board_name]].board[argumnets[:x].to_i] }"
        end
      when 'stack'
        puts "Stack: #{ argumnets[:name] } \n"
        puts " size: #{ @game.stacks[argumnets[:name]].size } \n"
        if @game.stacks[argumnets[:name]].connectY != nil
          puts " connects to: #{@game.stacks[argumnets[:name]].connect_board} [#{ @game.stacks[argumnets[:name]].connectX }, #{ @game.stacks[argumnets[:name]].connectY }] \n"
        else
          puts " connects to: #{@game.stacks[argumnets[:name]].connect_board} [#{ @game.stacks[argumnets[:name]].connectX }, #{ @game.stacks[argumnets[:name]] }] \n"
        end
      when 'rules'
        @game.rules.each { |rule| puts "#{Rule.deserialize(rule)}" }

        #puts " pieces: "
      #@game.stacks[argumnets[:name]].pieces.each { |piece| puts "piece #{ piece.name }," }

    end
  end
end

io = HighLine.new
ggpTerminal = GGPTerminalUI.new
console = CLI::Console.new(io)

console.addCommand('new', ggpTerminal.method(:new))
console.addCommand('load', ggpTerminal.method(:load))
console.addCommand('delete', ggpTerminal.method(:delete))
console.addCommand('generate', ggpTerminal.method(:generate))
console.addCommand('save', ggpTerminal.method(:save))
console.addCommand('update', ggpTerminal.method(:update))
console.addCommand('show', ggpTerminal.method(:show))
console.addExitCommand('q')

console.start("%s> ", [Dir.method(:pwd)])