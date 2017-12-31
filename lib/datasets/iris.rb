require "csv"

require_relative "dataset"

module Datasets
  class Iris < Dataset
    Record = Struct.new(:sepal_length,
                        :sepal_width,
                        :petal_length,
                        :petal_width,
                        :class)

    def initialize
      super()
      @metadata.name = "iris"
      @metadata.url = "https://archive.ics.uci.edu/ml/datasets/Iris"
    end

    def each
      return to_enum(__method__) unless block_given?

      open_data do |csv|
        csv.each do |row|
          next if row[0].nil?
          record = Record.new(*row)
          yield(record)
        end
      end
    end
    
    def description
      open_description do |desc|
        desc.each do |line|
          puts "#{line.chomp}"
        end
      end
    end

    private
    def open_data
      data_path = cache_dir_path + "iris.csv"
      unless data_path.exist?
        data_url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
        download(data_path, data_url)
      end
      CSV.open(data_path, converters: [:numeric]) do |csv|
        yield(csv)
      end
    end

    def open_description
      data_path = cache_dir_path + "iris.names"
      unless data_path.exist?
        data_url = "http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.names"
        download(data_path, data_url)
      end
      File.open(data_path) do |desc|
        yield(desc)
      end
    end
  end
end
