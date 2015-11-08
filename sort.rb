class Elephant
	attr_reader :weight, :iq

	def initialize(weight, iq)
		@weight = weight
		@iq			= iq # in hundredths of IQ points
	end

	def to_s
		"(( °j° %5i  )),,) %5i  (,,  )~" % [@iq, @weight]
	end
end

class Input
	def initialize(filename)
		@filename = filename
	end

	def to_a
puts "parse: #{parse}"
		parse
	end

	private

	def parse
		[].tap do |elephants|
			IO.foreach(@filename) do |line|
				elephants << Elephant.new(*line.split(' ').map(&:to_i) )
			end
		end
	end
end

class ElephantSort
	def initialize(filename)
		@filename = filename
		@input = Input.new(@filename).to_a
		@output = []
	end

	def run
		puts "By Weight ASC:"
		puts ByWeight.new(@input).run
		puts "By IQ ASC: "
		puts ByIq.new(@input).run
	end
end

module SortBy
	def initialize(elephants)
		@elephants = elephants
	end
end

class Foo
end

class ByWeight
	include SortBy

	def run
		@elephants.sort_by { |e| e.weight }
	end
end

class ByIq
	include SortBy

	def run
		@elephants.sort_by { |e| e.iq }
	end
end

ElephantSort.new(ARGV[1] || 'input.txt').run
