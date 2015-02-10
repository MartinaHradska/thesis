require './rule'
module PlayerGenerator
  def generate_role
    [Relation.new('role',@name)]
  end
  def generate_base_for_role
    [Relation.new('base', Relation.new('control', @name))]
  end
  def generate_init_for_player_round
    @rounds.include?(1) ? [Relation.new('init', Relation.new('control', @name))] : []
  end
  def generate_update_for_player_round
    update = []
    @rounds.each do |round|
      if round == 1
        update << Rule.new(Relation.new('next', Relation.new('control', @name)), Relation.new('true', Relation.new('round', Game.rounds)))
      else
        update << Rule.new(Relation.new('next', Relation.new('control', @name)), Relation.new('true', Relation.new('round', round - 1)))
      end
    end
    update
  end
  def generate_legal_player
    legal = []
      rounds = *(1 .. Game.rounds)
      noop_rounds = rounds - @rounds
      noop_rounds.each { |round| legal << Rule.new(Relation.new('legal',@name,'noop'), Relation.new('true', Relation.new('round', round))) }
    legal
  end
  def generate_player
    generate_role + generate_base_for_role + generate_init_for_player_round + generate_legal_player + generate_update_for_player_round
  end
end