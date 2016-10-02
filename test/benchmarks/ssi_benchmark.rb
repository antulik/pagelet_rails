
require 'active_support/all'
require 'csv'
require 'pp'

root_url = 'http://local.dev/dyno/benchmark.html'

delays = [0, 10, 20, 30, 50, 100, 200]
sizes = (1..10).to_a
modes = ['inline']

rows = []
sizes.map do |size|

  delays.each do |delay|
    r = []
    r << size
    r << delay

    modes.each do |mode|
      params = {
        remote: mode,
        sleep: delay,
        size: size
      }
      url = "#{root_url}?#{params.to_query}"

      args = %W(ab -n 50 -e output.csv -l #{url})
      # puts args
      system(*args)

      sleep 1
      arr_of_arrs = CSV.read("./output.csv")
      last_row = arr_of_arrs.last(10).first
      time = last_row.last

      # File.delete('./output.csv')
      # puts time
      r << time
    end

    rows << r.join("\t")
  end

end

puts rows
