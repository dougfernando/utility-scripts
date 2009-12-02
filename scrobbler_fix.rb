# Script to remove duplicate items from last.fm submission xml file
# author: Douglas Fernando da Silva <doug.fernando at gmail.com>

require "rexml/document"
include REXML

history = nil
File.open(ARGV[0]) do |file|
  history = Document.new(file)
  tracks_to_remove = []

  last_timestamp = nil
  history.elements.each("submissions/item") do |element|
    ts = element.elements["timestamp"].text
    if ts == last_timestamp
      puts "Track: " + element.elements["track"].text + " is repeated"
      tracks_to_remove.push(element);
    else
      last_timestamp = ts
    end
  end

  root = history.elements["submissions/item"].parent
  for i in 0..tracks_to_remove.length-1 do
    element = root.delete(tracks_to_remove[i])
  end
end

formatter = REXML::Formatters::Default.new
File.open(ARGV[0], "w") do |result|
  formatter.write(history, result)
end
