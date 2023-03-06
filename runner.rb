# runner.rb
require './lib/stat_tracker'

game_path = './data/games.csv'
team_path = './data/teams.csv'
game_teams_path = './data/game_teams.csv'

locations = {
  games: game_path,
  teams: team_path,
  game_teams: game_teams_path
}

stat_tracker = StatTracker.from_csv(locations)

puts "Statistics Examples\n\n"
puts "Average Goals By Season: #{stat_tracker.average_goals_by_season}\n\n"
puts "Best Offense: #{stat_tracker.best_offense}\n\n"
puts "Percentage of Home Wins: #{stat_tracker.percentage_home_wins * 100}%\n\n"