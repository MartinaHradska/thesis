require './relation'
module PredefinedRelations
  VAR_FIRST_X = '?x1'
  VAR_SECOND_X = '?x2'
  VAR_TEMP_X = '?x'
  VAR_FIRST_Y = '?y1'
  VAR_SECOND_Y = '?y2'
  VAR_TEMP_Y = '?y'
  VAR_TILE_VALUE = '?val'
  VAR_PIECE = '?piece'
  VAR_PLAYER = '?player'
  VAR_PIECE_TYPE = '?piecetype'

  ROLE = Relation.new('role', VAR_PLAYER)

  X1_INDEX = Relation.new('width_index', VAR_FIRST_X)
  X2_INDEX= Relation.new('width_index', VAR_SECOND_X)
  Y1_INDEX = Relation.new('height_index', VAR_FIRST_Y)
  Y2_INDEX = Relation.new('height_index', VAR_SECOND_Y)

  TILE_VALUE = Relation.new('tile_value', VAR_TILE_VALUE)
  PIECE_VAUE = Relation.new('piece_value', VAR_PIECE)
  PIECE_CHECK = Relation.new('piece_check', VAR_PIECE, VAR_PLAYER, VAR_PIECE_TYPE)
  PIECE_TYPE_LEGAL_1D = Relation.new('piece_type_legal', VAR_PIECE_TYPE, VAR_FIRST_X, VAR_SECOND_X)
  PIECE_TYPE_LEGAL_2D = Relation.new('piece_type_legal', VAR_PIECE_TYPE, VAR_FIRST_X, VAR_FIRST_Y, VAR_SECOND_X, VAR_SECOND_Y)

  TILE_1D_TILE_VALUE = Relation.new('tile', VAR_FIRST_X, VAR_TILE_VALUE)
  TILE_2D_TILE_VALUE = Relation.new('tile', VAR_FIRST_X, VAR_FIRST_Y, VAR_TILE_VALUE)
  TILE_1D_PIECE = Relation.new('tile', VAR_FIRST_X, VAR_PIECE)
  TILE_2D_PIECE = Relation.new('tile', VAR_FIRST_X, VAR_FIRST_Y, VAR_PIECE)
  TILE_1D_TILE_VALUE_PIECE = Relation.new('tile', VAR_FIRST_X, VAR_TILE_VALUE, VAR_PIECE)
  TILE_2D_TILE_VALUE_PIECE = Relation.new('tile', VAR_FIRST_X, VAR_FIRST_Y, VAR_TILE_VALUE, VAR_PIECE)

  MARK_X = Relation.new('mark',VAR_FIRST_X)
  MARK_XY = Relation.new('mark', VAR_FIRST_X, VAR_FIRST_Y)
  MOVE_X = Relation.new('move', VAR_FIRST_X, VAR_SECOND_X, VAR_PIECE)
  MOVE_XY = Relation.new('move', VAR_FIRST_X, VAR_FIRST_Y, VAR_SECOND_X, VAR_SECOND_Y, VAR_PIECE)

  MOVE_1D_FROM_TILE = Relation.new('tile', VAR_FIRST_X, VAR_PIECE)
  MOVE_2D_FROM_TILE = Relation.new('tile', VAR_FIRST_X, VAR_FIRST_Y, VAR_PIECE)
end