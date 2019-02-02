require 'byebug'
require_relative 'src/db'
require_relative 'src/checker'
require_relative 'src/notifier'


def main(ip)
  ip ||= "192.168.0.0/24"

  db = FileDB.new()

  checker = Checker.new(ip, db)
  unless checker.is_valid()
    puts "invalid ip"
    exit(1)
  end
  notifier = Notifier.new()

  msg_list = ["#{get_time()} ip-checker starting"]
  #list = checker.check()[0].map{|ip,info|"#{ip}/#{info.desc}"}
  #puts <<~"EOS"
  #  \033[2J
  #  == ip-checker ==
  #  #{list.join("\n")}
  #  ===
  #EOS

  loop do
    msg_delta = []
    ip_inc, ip_dec = checker.check()
    ip_inc.each do |ip, info|
      notifier.notify({"title": "ip join", "message": "#{ip}/#{info.desc} join"})
      msg_delta << "#{get_time()} << [join] #{ip}/#{info.desc}"
    end
    ip_dec.each do |ip, info|
      notifier.notify({"title": "ip left", "message": "#{ip}/#{info.desc} lost"})
      msg_delta << "#{get_time()} >> [left] #{ip}/#{info.desc}"
    end

    if ! msg_delta.empty?
      list = checker.cache().map{|ip,info|"#{ip}/#{info.desc}"}
      print "\033[2J"
      puts <<~"EOS"
        \033[2J
        == ip-checker ==
        #{list.join("\n")}
        ===
      EOS
      msg_list = (msg_list+msg_delta).last(5)
      puts msg_list.join("\n")
    end

    sleep 60
  end
end

def get_time()
  Time.now.strftime("%H:%M")
end

main(ARGV[0])

