ARGV.each do |arg|
	puts "analyzing file: #{arg}"

	input_line = []
	File.open(arg, "r").each_line { |line| input_line.push(line) }

	result = Hash.new

	input_line.each do |line|
		words = line.chomp.split
		words.each do |w|
			if result.has_key?(w)
				result[w] = result[w] + 1
			else
				result[w] = 1
			end
		end

	end
  
	result.sort_by { |key, value| value }.each do |k, v|
		puts k.to_s + "|" + v.to_s
	end
end