require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'csv'
require 'awesome_print'

class MPEX

	attr_accessor :noko, :data

	COLUMNS = [
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

				{
					type: option.scan(/\..+\.([C|P])\d+/).flatten![0],
					strike: option.scan(/[C|P](\d+)/).flatten![0].to_f,
					expiry: option[-1],
					bid: node.css("td:eq(2)").text.to_f,
					ask: next_row.css("td:eq(2)").text.to_f,
					last: node.css("td:eq(3)").text.to_f,
					min: node.css("td:eq(4)").text.to_f,
					max: next_row.css("td:eq(4)").text.to_f,
					volume_day: node.css("td:eq(5)").text.to_f,
					volume_month: next_row.css("td:eq(5)").text.to_f
				}
			end
			
		end

		@data.reject! {|d| d.nil?}

	end

	def to_csv
		CSV.open("mpex.csv", "w") do |csv|
			csv << COLUMNS

			@data.each do |d|
				
				csv << COLUMNS.map do |c|
					d[c.to_sym]
				end
			end
		end
	end
end

# Execute code ===========================

# m = MPEX.new
# m.to_csv