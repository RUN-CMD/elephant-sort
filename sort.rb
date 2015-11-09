require 'benchmark'

# weights must be strictly increasing, 
# and IQs must be strictly decreasing.

class Elephant
	attr_reader :weight, :iq, :name
	attr_accessor :parent

	def initialize(weight, iq, name = nil)
		@weight = weight.to_i
		@iq			= iq.to_i # in hundredths of IQ points
		@name		= name
	end

	def to_s
		if name
			"(°j° #{name})~"
		else
			"(( °j° %5i ))(,,) %5i (,,)~" % [@iq, @weight]
		end
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
				elephants << Elephant.new(*line.split(' ') )
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
		Sampler.new(@input).tap do |s|
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

class Sample

	def initialize(elephant = nil)
		@elephants = []
		self.<< elephant unless elephant.nil?
	end

	def <<(elephant, index = nil)
		index = @elephants.size - 1 if index.nil? # End of the Herd

		if valid_elephant?(@elephants[index], elephant)
			elephant.parent = index
			@elephants.insert(index, elephant)
		else
			self.<<(elephant, elephant.parent)
		end
	end

	def first
		@elephants.first
	end

	def size
		@elephants.size
	end

	def valid_elephant?(baseline, other)
		unless baseline.respond_to?(:weight) &&
					 other.respond_to?(:weight) &&
					 baseline.respond_to?(:iq) &&
					 other.respond_to?(:iq)
			raise ArgumentError unless baseline.nil?
		end

		return true if baseline.nil?

		baseline.weight <= other.weight &&
		baseline.iq 		>= other.iq
	end
end

class Sampler
	include SortBy

	class Cell
		attr_accessor :cost
		attr_accessor :parent
	end

	class Compare
		attr_reader :elephant, :other

		def new(elephant, other)
			@elephant, @other = elephant, other
		end

		def valid?(elephant, other)
			elephant.weight <= other.weight &&
			elephant.iq 		>= other.iq
		end

		#TODO nope
		def compare
			raise 'donut work'
			return 0 if elephant.weight == other.weight &&
									elephant.iq 		== other.iq

			return -1 if elephant.weight <  other.weight &&
									 elephant.iq     <= other.iq
			return 1
		end
	end

	def results
		@results
	end

	def traverse(i)
		if Compare.new(elephants[i], elephants[i + 1]).compare
			traverse(i + 1)
		end
	end

	def run
		@samples = []

		# For each input elephant
		# create a tree of elephants below that one that meet our requirements
		@elephants.each_with_index do |elephant, index|
			tmp_elephants = @elephants.dup
			@samples << Sample.new(tmp_elephants.slice(index) ).tap do |sample|
				puts "** #{sample.first} took leadership of a new Herd!"
				while elephant = tmp_elephants.shift
					if sample << elephant
						puts "** Added #{elephant} to Herd lead by #{sample.first}. " +
								 "She is the #{sample.size}th member of the Herd."
					else
						# puts "** Didn't accept #{elephant} into Herd lead by #{sample.first}"
					end
				end
			end
		end

		puts "** #{@samples.count} Heards of sizes: #{@samples.map(&:size)}"

		require 'pry'; binding.pry

		@samples
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
