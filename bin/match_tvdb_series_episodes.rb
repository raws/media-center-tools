require 'json'
require 'shellwords'

require_relative '../lib/episode'

tvdb = open(File.expand_path(ARGV[0])) { |io| JSON.load(io) }.map do |json|
  Episode.new json['season'], json['episode'], json['title']
end

files = File.readlines(File.expand_path(ARGV[1])).map(&:strip)
series_title = ARGV[2]
new_path_base = ARGV[3]
matches = []

files.each do |file_path|
  file_episode_title = File.basename(file_path, '.*')
  episode = tvdb.find { |episode| episode.title == file_episode_title }

  if episode
    season_dir = "Season #{episode.season}"
    new_file = '%s - S%02dE%02d - %s%s' % [series_title, episode.season, episode.episode,
      episode.title, File.extname(file_path)]
    new_path = File.join(new_path_base, season_dir, new_file)
    matches << [file_path, episode, new_path]
  end
end

matches.each do |match|
  puts Shellwords.join(['mkdir', '-p', File.dirname(match.last)])
  puts Shellwords.join(['mv', match.first, match.last])
end

unmatched_files = files - matches.map { |match| match[0] }
unmatched_tvdb = tvdb - matches.map { |match| match[1] }

$stderr.puts
$stderr.puts 'Unmatched files:'
unmatched_files.sort.each { |file_path| $stderr.puts(file_path) }

$stderr.puts
$stderr.puts 'Unmatched TVDB episodes:'
unmatched_tvdb.sort_by(&:title).each { |episode| $stderr.puts(episode) }
