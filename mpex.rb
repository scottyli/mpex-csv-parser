require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'csv'
require 'awesome_print'

class MPEX

  attr_accessor :noko, :data

  def initialize
    link = "http://mpex.co"
    html = open(link).read
    @noko = Nokogiri::HTML(html).css("table tr")
    self.build_rows
  end

  def build_rows
    @data = @noko.each_with_index.map do |node, index|

      option = node.css("td a").text

      if !option.empty? && option[0] == "O"
        next_row = @noko[index + 1]       
        
        type = option.scan(/\..+\.([C|P])\d+/).flatten![0]
        strike = option.scan(/[C|P](\d+)/).flatten![0]
        expiry = option[-1]       
        bid = node.css("td:eq(2)").text.to_f
        ask = next_row.css("td:eq(2)").text.to_f
        last = node.css("td:eq(3)").text.to_f
        min = node.css("td:eq(4)").text.to_f
        max = next_row.css("td:eq(4)").text.to_f
        volume_day = node.css("td:eq(5)").text.to_f
        volume_month =next_row.css("td:eq(5)").text.to_f

        {
          type: type,
          strike: strike,
          expiry: expiry,
          bid: bid,
          ask: ask,
          last: last,
          min: min,
          max: max,
          volume_day: volume_day,
          volume_month: volume_month
        }
      end
      
    end

    @data.reject! {|d| d.nil?}

  end

  def to_csv
    CSV.open("mpex.csv", "w") do |csv|
      csv << [
        "type",
        "strike",
        "expiry",
        "bid",
        "ask",
        "last",
        "min",
        "max",
        "volume_day",
        "volume_month"
      ]

      @data.each do |d|
        csv << [
          d[:type],
          d[:strike],
          d[:expiry],
          d[:bid],
          d[:ask],
          d[:last],
          d[:min],
          d[:max],
          d[:volume_day],
          d[:volume_month]
        ]
      end
    end
  end
end

# Execute code ===========================

# m = MPEX.new
# m.to_csv