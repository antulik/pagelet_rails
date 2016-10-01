
require 'active_support/all'
require 'csv'
require 'pp'

root_url = 'http://local.dev/dyno/test.html'

delays = [0]
sizes = (15..20).to_a
modes = ['inline']

rows = []
sizes.map do |size|

  delays.each do |delay|
    r = []
    r << "#{size} x #{delay}ms"

    modes.each do |mode|
      params = {
        remote: mode,
        sleep: delay,
        size: size
      }
      url = "#{root_url}?#{params.to_query}"

      args = %W(ab -n 100 -e output.csv -l #{url})
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
