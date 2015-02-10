require './tile'
require './predefined_relations'
require './rule'
require './custom_condition'
module GameBoardGenerator
  include PredefinedRelations
  def generate_base_board
    base = []
    case
      when !@is_2d && has_tile_values? && !has_pieces?
        base << Rule.new(Relation.new('base', TILE_1D_TILE_VALUE), X1_INDEX, TILE_VALUE)
      when @is_2d && has_tile_values? && !has_pieces?
        base << Rule.new(Relation.new('base', TILE_2D_TILE_VALUE), X1_INDEX, Y1_INDEX, TILE_VALUE)
      when !@is_2d && !has_tile_values? && has_pieces?
        base << Rule.new(Relation.new('base', TILE_1D_PIECE), X1_INDEX, PIECE_VAUE)
      when @is_2d && !has_tile_values? && has_pieces?
        base << Rule.new(Relation.new('base', TILE_2D_PIECE), X1_INDEX, Y1_INDEX, PIECE_VAUE)
      when !@is_2d && has_tile_values? && has_pieces?
        base << Rule.new(Relation.new('base', TILE_1D_TILE_VALUE_PIECE), X1_INDEX, TILE_1D_PIECE, PIECE_VAUE)
      when @is_2d && has_tile_values? && has_pieces?
        base << Rule.new(Relation.new('base', TILE_2D_TILE_VALUE_PIECE), X1_INDEX, Y1_INDEX, TILE_1D_PIECE, PIECE_VAUE)
    end
    base
  end
#Pro kazdeho hrace definovano, ktere tile_value muze byt
  def generate_input_board
    input = []
    case
      when !@is_2d && has_tile_values? && !has_pieces?
        input << Rule.new(Relation.new('input', VAR_PLAYER, MARK_X), ROLE, X1_INDEX)
      when @is_2d && has_tile_values? && !has_pieces?
        input << Rule.new(Relation.new('input', VAR_PLAYER, MARK_XY), ROLE, X1_INDEX, Y1_INDEX)
      when !@is_2d && has_pieces?
        input << Rule.new(Relation.new('input', VAR_PLAYER, MOVE_X), ROLE, X1_INDEX, X2_INDEX, PIECE_VAUE)
      when !@is_2d && has_pieces?
        input << Rule.new(Relation.new('input', VAR_PLAYER, MOVE_XY), ROLE, X1_INDEX, Y1_INDEX, X2_INDEX, Y2_INDEX, PIECE_VAUE)
    end
    input
  end
  def generate_init_board
    init = []
    case
      when !@is_2d && has_tile_values? && !has_pieces?
        (1 .. @width).each{ |x| init << Relation.new('init', Relation.new('tile', x, @board[x-1].tile_values[0])) }
      when @is_2d && has_tile_values? && !has_pieces?
        (1 .. @width).each{ |x| (1 .. @height).each { |y| init << Relation.new('init', Relation.new('tile', x, y, @board[x-1][y-1].tile_values[0])) } }
      when !@is_2d && !has_tile_values? && has_pieces?
        (1 .. @width).each{ |x| init << Relation.new('init', Relation.new('tile', x, @board[x-1].pieces[0])) }
      when @is_2d && !has_tile_values? && has_pieces?
        (1 .. @width).each{ |x| (1 .. @height).each { |y| init << Relation.new('init', Relation.new('tile', x, y, @board[x-1][y-1].pieces[0])) } }
      when !@is_2d && has_tile_values? && has_pieces?
        (1 .. @width).each{ |x| init << Relation.new('init', Relation.new('tile', x, @board[x-1].tile_values[0], @board[x-1].pieces[0])) }
      when @is_2d && has_tile_values? && has_pieces?
        (1 .. @width).each{ |x| (1 .. @height).each { |y| init << Relation.new('init', Relation.new('tile', x, y, board[x-1][y-1].tile_value, @board[x][y].pieces[0])) } }
    end
    init
  end
  def generate_legal_board
    legal = []
    conds = []
    @legal_conditions.each{ |cond_array| conds << cond_array.conditions.map { |cond| Relation.new('true', cond )} }
    player_control = Relation.new('true',Relation.new('control', VAR_PLAYER))
    legal_mark_1d = Relation.new('legal', VAR_PLAYER, MARK_X)
    legal_mark_2d = Relation.new('legal', VAR_PLAYER, MARK_XY)
    legal_move_1d = Relation.new('legal', VAR_PLAYER, MOVE_X)
    legal_move_2d = Relation.new('legal', VAR_PLAYER, MOVE_XY)
    from_1d = Relation.new('true', MOVE_1D_FROM_TILE)
    from_2d = Relation.new('true', MOVE_2D_FROM_TILE)
    case
      when !@is_2d && has_tile_values? && !has_pieces?
        conds.each do |c|
          if c.empty?
            legal << Rule.new(legal_mark_1d, player_control)
          else
            legal << Rule.new(legal_mark_1d, player_control, *c)
          end
        end
      when @is_2d && has_tile_values? && !has_pieces?
        conds.each do |c|
          if c.empty?
            legal << Rule.new(legal_mark_2d, player_control)
          else
            legal << Rule.new(legal_mark_2d, player_control, *c)
          end
        end
      when !@is_2d && !has_tile_values? && has_pieces?
        conds.each do |c|
          if c.empty?
            legal << Rule.new(legal_move_1d, player_control, PIECE_CHECK, PIECE_TYPE_LEGAL_1D, from_1d)
          else
            legal << Rule.new(legal_move_1d, player_control, PIECE_CHECK, PIECE_TYPE_LEGAL_1D, from_1d, *c)
          end
        end
      when @is_2d && !has_tile_values? && has_pieces?
        conds.each do |c|
          if c.empty?
            legal << Rule.new(legal_move_2d, player_control, PIECE_CHECK, PIECE_TYPE_LEGAL_2D, from_2d)
          else
            legal << Rule.new(legal_move_2d, player_control, PIECE_CHECK, PIECE_TYPE_LEGAL_2D, from_2d, *c)
          end
        end
    end
    legal
  end
  def generate_update_tile_value_outside_mark
    update = []
    mark_1d = Relation.new('does', VAR_PLAYER, MARK_X)
    mark_2d = Relation.new('does', VAR_PLAYER, MARK_XY)
    distinct_x = Relation.new('distinct', VAR_FIRST_X, VAR_TEMP_X)
    distinct_y = Relation.new('distinct', VAR_FIRST_Y, VAR_TEMP_Y)
    tile_1d = Relation.new('true', TILE_1D_TILE_VALUE)
    tile_2d = Relation.new('true', TILE_2D_TILE_VALUE)
    @update_mark_outside_conditions.each do |cond_array|
      conds = cond_array.conditions.map { |cond| Relation.new('true', cond )}
      next_tile_1d = Relation.new('next', Relation.new('tile', VAR_TEMP_X, cond_array.value))
      next_tile_2d = Relation.new('next', Relation.new('tile', VAR_TEMP_X, VAR_TEMP_Y, cond_array.value))
      if @is_2d
        update << Rule.new(next_tile_2d, mark_2d, distinct_x, tile_2d, *conds)
        update << Rule.new(next_tile_2d, mark_2d, distinct_y, tile_2d, *conds)
      else
        update << Rule.new(next_tile_1d, mark_1d, distinct_x, tile_1d, *conds)
      end
    end
    update
  end
  def generate_update_tile_value_marked
    update = []
    mark_1d = Relation.new('does', VAR_PLAYER, MARK_X)
    mark_2d = Relation.new('does', VAR_PLAYER, MARK_XY)
    @update_marked_conditions.each do |cond_array|
      next_tile_1d = Relation.new('next',Relation.new('tile', VAR_TEMP_X, cond_array.value))
      next_tile_2d = Relation.new('next',Relation.new('tile', VAR_TEMP_X, VAR_TEMP_Y, cond_array.value))
      conds = cond_array.conditions.map { |cond| Relation.new('true', cond )}
      if @is_2d
        update << Rule.new(next_tile_2d, mark_2d, *conds)
      else
        update << Rule.new(next_tile_1d, mark_1d, *conds)
      end
    end
    update
  end
  def generate_update_piece_move_outside(piece = nil, condition_ids)
    update = []
    move_1d = Relation.new('does', VAR_PLAYER, MOVE_X)
    move_2d = Relation.new('does', VAR_PLAYER, MOVE_XY)
    distinct_x1 = Relation.new('distinct', VAR_FIRST_X, VAR_TEMP_X)
    distinct_x2 = Relation.new('distinct', VAR_SECOND_X, VAR_TEMP_X)
    distinct_y1 = Relation.new('distinct', VAR_FIRST_Y, VAR_FIRST_Y)
    distinct_y2 = Relation.new('distinct', VAR_SECOND_Y, VAR_SECOND_Y)
    piece_1d = Relation.new('true', Relation.new('tile', VAR_TEMP_X, VAR_PIECE))
    piece_2d = Relation.new('true', Relation.new('tile', VAR_TEMP_X, VAR_TEMP_Y, VAR_PIECE))
    conds = condition_ids.map{ |id| Relation.new('true',@conditions[id]) }
    if piece == nil
      next_tile_1d = Relation.new('next',Relation.new('tile', VAR_TEMP_X, VAR_PIECE))
      next_tile_2d = Relation.new('next',Relation.new('tile', VAR_TEMP_X, VAR_TEMP_Y, VAR_PIECE))
      case
        when @is_2d && condition_id == nil
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_x2, piece_2d)
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_y2, piece_2d)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_x2, piece_2d)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_y2, piece_2d)
        when @is_2d && condition_id != nil
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_x2, piece_2d, *conds)
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_y2, piece_2d, *conds)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_x2, piece_2d, *conds)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_y2, piece_2d, *conds)
        when !@is_2d && condition_id == nil
          update << Rule.new(next_tile_1d, move_1d, distinct_x1, distinct_x2, piece_1d)
        when !@is_2d && condition_id != nil
          update << Rule.new(next_tile_1d, move_1d, distinct_x1, distinct_x2, piece_1d, *conds)
      end
    else
      next_tile_1d = Relation.new('next',Relation.new('tile', VAR_TEMP_X,piece))
      next_tile_2d = Relation.new('next',Relation.new('tile', VAR_TEMP_X, VAR_TEMP_Y,piece))
      case
        when @is_2d && condition_id == nil
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_x2)
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_y2)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_x2)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_y2)
        when @is_2d && condition_id != nil
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_x2, *conds)
          update << Rule.new(next_tile_2d, move_2d, distinct_x1, distinct_y2, *conds)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_x2, *conds)
          update << Rule.new(next_tile_2d, move_2d, distinct_y1, distinct_y2, *conds)
        when !@is_2d && condition_id == nil
          update << Rule.new(next_tile_1d, move_1d, distinct_x1, distinct_x2)
        when !@is_2d && condition_id != nil
          update << Rule.new(next_tile_1d, move_1d, distinct_x1, distinct_x2, *conds)
      end
    end
    update
  end
  def generate_update_piece_move_from(piece, *condition_ids)
    update = []
    move_1d = Relation.new('does', VAR_PLAYER, Relation.new('move', VAR_FIRST_X, VAR_SECOND_X, piece))
    move_2d = Relation.new('does', VAR_PLAYER, Relation.new('move', VAR_FIRST_X, VAR_FIRST_Y, VAR_SECOND_X, VAR_SECOND_Y, piece))
    distinct_x2 = Relation.new('distinct', VAR_FIRST_X, VAR_SECOND_X)
    distinct_y2 = Relation.new('distinct', VAR_FIRST_Y, VAR_SECOND_Y)
    from_1d = Relation.new('true', Relation.new('tile', VAR_FIRST_X, VAR_PIECE))
    from_2d = Relation.new('true', Relation.new('tile', VAR_FIRST_X, VAR_FIRST_Y, VAR_PIECE))
    next_tile_1d = Relation.new('next', MOVE_1D_FROM_TILE)
    next_tile_2d = Relation.new('next', MOVE_2D_FROM_TILE)
    distinct_piece = Relation.new('distinct', VAR_PIECE, piece)
    conds = condition_ids.map{ |id| Relation.new('true',@conditions[id]) }
    case
      when @is_2d && condition_ids == nil
        update << Rule.new(next_tile_2d, move_2d, distinct_x2, from_2d, distinct_piece)
        update << Rule.new(next_tile_2d, move_2d, distinct_y2, from_2d, distinct_piece)
      when @is_2d && condition_ids != nil
        update << Rule.new(next_tile_2d, move_2d, distinct_x2, from_2d, distinct_piece, *conds)
        update << Rule.new(next_tile_2d, move_2d, distinct_y2, from_2d, distinct_piece, *conds)
      when !@is_2d && condition_ids == nil
        update << Rule.new(next_tile_1d, move_1d, distinct_x2, from_1d, distinct_piece)
      when !@is_2d && condition_ids != nil
        update << Rule.new(next_tile_1d, move_1d, distinct_x2, from_1d, distinct_piece, *conds)
    end
    update
  end
  def generate_update_piece_move_to(piece, *condition_ids)
    update = []
    move_1d = Relation.new('does', VAR_PLAYER, Relation.new('move', VAR_FIRST_X, VAR_SECOND_X, piece))
    move_2d = Relation.new('does', VAR_PLAYER, Relation.new('move', VAR_FIRST_X, VAR_FIRST_Y, VAR_SECOND_X, VAR_SECOND_Y, piece))
    distinct_x2 = Relation.new('distinct', VAR_FIRST_X, VAR_SECOND_X)
    distinct_y2 = Relation.new('distinct', VAR_FIRST_Y, VAR_SECOND_Y)
    to_1d = Relation.new('true', Relation.new('tile', VAR_SECOND_X, VAR_PIECE))
    to_2d = Relation.new('true', Relation.new('tile', VAR_SECOND_X, VAR_SECOND_Y, VAR_PIECE))
    next_tile_1d = Relation.new('next', Relation.new('tile', VAR_SECOND_X, VAR_PIECE))
    next_tile_2d = Relation.new('next', Relation.new('tile', VAR_SECOND_X, VAR_SECOND_Y, VAR_PIECE))
    conds = condition_ids.map{ |id| Relation.new('true',@conditions[id]) }
    case
      when @is_2d && condition_ids == nil
        update << Rule.new(next_tile_2d, move_2d, to_2d, distinct_x2)
        update << Rule.new(next_tile_2d, move_2d, to_2d, distinct_y2)
      when @is_2d && condition_ids != nil
        update << Rule.new(next_tile_2d, move_2d, to_2d, distinct_x2, *conds)
        update << Rule.new(next_tile_2d, move_2d, to_2d, distinct_y2, *conds)
      when !@is_2d && condition_ids == nil
        update << Rule.new(next_tile_1d, move_1d, to_1d, distinct_x2)
      when !@is_2d && condition_ids != nil
        update << Rule.new(next_tile_1d, move_1d, to_1d, distinct_x2, *conds)
    end
    update
  end
  def generate_board
    rules = generate_base_board + generate_input_board + generate_init_board + generate_width
    rules += generate_height if @is_2d
    rules += generate_legal_board
    if has_tile_values?
      rules += generate_update_tile_value_outside_mark
      rules += generate_update_tile_value_marked
    end
    if has_pieces?

    end
    rules
  end
  def generate_width
    (1 .. @width).map { |index| Relation.new('width_index',index) }
  end
  def generate_height
    (1 .. @height).map { |index| Relation.new('height_index',index) }
  end
  def generate_board_mark(player)

  end
  def generate_board_move(player)

  end
end