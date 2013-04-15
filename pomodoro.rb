# Pomodoro Timer for console
# Author: Douglas Silva

def pomodoro(minutes, task)
    while minutes > 0
        puts task + " - " + minutes.to_s + " minutes left"
        (1..60).each do |sec|
            print '.'
            sleep 1
            puts "" if sec == 60
        end
        minutes = minutes - 1
    end

    puts ""
    puts ""
    puts "##########################################"
    puts "## FINALIZADO ############################"
    puts "##########################################"
end

input_minutes = ARGV[0].to_i
input_task = ARGV[1, ARGV.size()].inject { |result, item| result + " " + item } 

pomodoro input_minutes, input_task

