require 'benchmark'

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

	def results
		Foo.new(@input).tap do |s|
			s.run
			puts s.report
		end
	end

	def benchmark
		Benchmark.bmbm do |b|
			b.report("By Weight ASC") do
				ByWeight.new(@input).tap do |s|
					s.run
				end
			end

			b.report("By IQ ASC") do
				ByIq.new(@input).tap do |s|
					s.run
				end
			end
		end
	end
end

module SortBy
	def count
		@elephants.count
	end

	def initialize(elephants)
		@elephants = elephants
	end

	def report
		[count, results.join("\n")].join("\n")
	end
end

class Foo
	include SortBy

	def results
		@elephants
	end

	def run
		@elephants
	end
end

class ByWeight
	include SortBy

	def results
		run
	end

	def run
		@elephants.sort_by { |e| e.weight }
	end
end

class ByIq
	include SortBy

	def results
		run
	end

	def run
		@elephants.sort_by { |e| e.iq }
	end
end

ElephantSort.new(ARGV[1] || 'input.txt').results
ElephantSort.new(ARGV[1] || 'input.txt').benchmark
