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
      puts element.elements["track"].text
      tracks_to_remove.push(element);
    else
      last_timestamp = ts
    end
  end

  for i in 0..tracks_to_remove.length-1 do
    element_to_rm = tracks_to_remove[i]
    element = history.elements["submissions/item"].parent.delete(element_to_rm)
  end

end

formatter = REXML::Formatters::Default.new
File.open(ARGV[0], "w") do |result|
  formatter.write(history, result)
end
