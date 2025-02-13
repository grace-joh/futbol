require_relative 'stat_data'

class SeasonStats < StatData
  def initialize(locations)
    super(locations)
  end

  def winningest_coach(season)
    coach_games = Hash.new([0,0,0])
    game_teams_by_season(season).each do |game_team|
      coach_games[game_team.head_coach] = [0,0,0]
    end
    game_teams_by_season(season).each do |game_team|
      if game_team.result == "WIN"
        coach_games[game_team.head_coach][0] +=1 
      elsif game_team.result == "TIE"
        coach_games[game_team.head_coach][1] +=1
      elsif game_team.result == "LOSS"
      coach_games[game_team.head_coach][2] +=1
      else 
        return false
      end
    end
    coach_percentage = coach_games.transform_values do |details|
      details[0].fdiv(details[0] + details[1] + details[2])
   end
    coach_percentage.max_by {|coach, game_counters| game_counters}.first
  end

  def worst_coach(season)
    coach_games = Hash.new([0,0,0])
    game_teams_by_season(season).each do |game_team|
      coach_games[game_team.head_coach] = [0,0,0]
    end
    game_teams_by_season(season).each do |game_team|
      if game_team.result == "WIN"
        coach_games[game_team.head_coach][0] +=1 
      elsif game_team.result == "TIE"
        coach_games[game_team.head_coach][1] +=1
      elsif game_team.result == "LOSS"
      coach_games[game_team.head_coach][2] +=1
      else 
        return false
      end
    end
    coach_percentage = coach_games.transform_values do |details|
      details[0].fdiv(details[0] + details[1] + details[2])
   end
    coach_percentage.min_by {|coach, game_counters| game_counters}.first
  end

  def most_accurate_team(season)
    most_accurate_id = goals_to_shots_ratio(season).max_by { |_team_id, ratio| ratio }.first
    team_name_by_id(most_accurate_id)
  end

  def least_accurate_team(season)
    least_accurate_id = goals_to_shots_ratio(season).min_by { |_team_id, ratio| ratio }.first
    team_name_by_id(least_accurate_id)
  end

  def most_tackles(season)
    tackles_by_team = Hash.new(0)
    game_teams_by_season(season).each do |game_team|
      tackles_by_team[game_team.team_id] += game_team.tackles
    end
    max_team_id = tackles_by_team.max_by { |_team_id, tackles| tackles }.first
    team_name_by_id(max_team_id)
  end

  def fewest_tackles(season)
    tackles_by_team = Hash.new(0)
    game_teams_by_season(season).each do |game_team|
      tackles_by_team[game_team.team_id] += game_team.tackles
    end
    min_team_id = tackles_by_team.min_by { |_team_id, tackles| tackles }.first
    team_name_by_id(min_team_id)
  end

  def goals_to_shots_ratio(season)
    total_goals_by_team = Hash.new(0)
    total_shots_by_team = Hash.new(0)
    game_teams_by_season(season).each do |game_team|
      total_goals_by_team[game_team.team_id] += game_team.goals
      total_shots_by_team[game_team.team_id] += game_team.shots
    end
    total_goals_by_team.merge(total_shots_by_team) { |_team_id, total_goals, total_shots| (total_goals / total_shots.to_f) }
  end

  def team_name_by_id(team_id)
    all_teams.find { |team| team.team_id == team_id }.team_name
  end

  def games_by_season
    seasons = Hash.new([])
    all_games.each do |game|
      seasons[game.season] = []
    end
    seasons.each do |season, games_array|
      all_games.each do |game|
        games_array << game if game.season == season
      end
    end
    seasons
  end
  
  def game_teams_by_season(season)
    games_by_season[season].map do |game|
      all_game_teams.find_all do |game_by_team|
        game.id == game_by_team.game_id
      end
    end.flatten
  end
end
