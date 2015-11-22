require 'bundler/setup'
require 'json'
require 'nokogiri'

require_relative '../lib/episode'
require_relative '../lib/http_client'

tvdb_series_id = ARGV[0]
tvdb_series_url = "http://thetvdb.com/?id=#{tvdb_series_id}&tab=seasonall"

doc = Nokogiri::HTML(HttpClient.new.get(tvdb_series_url))
episodes = []

doc.css('table#listtable tr').each do |row|
  cells = row.css('td')

  if cells.size < 2
    $stderr.puts "Skipped table row: #{row}"
    next
  end

  season_and_episode = cells[0].text
  title = cells[1].text.strip

  if season_and_episode =~ /(\d+) x (\d+)/
    season = $~[1].to_i
    episode = $~[2].to_i

    episodes << Episode.new(season, episode, title)
  else
    $stderr.puts "Skipped table row: #{row}"
  end
end

episodes.sort_by! { |ep| [ep.season, ep.episode] }

puts JSON.dump(episodes.map(&:to_h))
