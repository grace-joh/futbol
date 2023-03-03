require 'csv'
require_relative 'game'
require_relative 'team'

class StatTracker 
  #include modules

  def self.from_csv(locations)
    new(locations)
  end

  attr_reader :game_data, :team_data, :game_teams_data

  def initialize(locations)
    @game_data = CSV.read locations[:games], headers: true, header_converters: :symbol
    @team_data = CSV.read locations[:teams], headers: true, header_converters: :symbol
    @game_teams_data = CSV.read locations[:game_teams], headers: true, header_converters: :symbol
  end

  def all_games
    @game_data.map do |row|
      Game.new(row)
    end
  end

  def all_teams
    @team_data.map do |row|
      team = Team.new(row)
      team.games = all_games.select { |game| game.home_id == team.team_id || game.away_id == team.team_id }
      team
    end
  end

  def all_game_teams
    @game_teams_data.map do |row|
      GameTeam.new(row)
    end
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
  #=====================================================================================================
  def game_teams_by_season(season)
    games_by_season[season].map do |game|
      all_game_teams.find_all do |game_by_team|
        game.id == game_by_team.game_id #array of gameteams
                                        #in that season
      end
    end.flatten
  end

  def winningest_coach(season)
    coach_games = Hash.new([])
    game_teams_by_season(season).each do |game_team|
        coach_games[game_team.head_coach] = []
    end
    game_teams_by_season(season).each do |game_team|
      coach_games[game_team.head_coach] << game_team if game_team.result == "WIN"
      end
    end
    # coach_games.each do |key, value|
    #   coach_counter = 0
    #   coach_counter  game_team_array.count
    # end
  end

  # hash.select {|k,v| v == hash.values.max }

  def highest_total_score
    all_games.map do |game|
      game.total_score
    end.max
  end

  def lowest_total_score
    all_games.map do |game|
      game.total_score
    end.min
  end


  def count_of_games_by_season
    game_count = {}
    data = games_by_season.map do |season, games|
      game_count[season] = games.count
    end
    game_count
  end

  def average_goals_by_season
    games_by_season.transform_values do |games_array|
      scores_array = games_array.map(&:total_score)
      (scores_array.sum.to_f / scores_array.length).round(2)
    end
  end
end