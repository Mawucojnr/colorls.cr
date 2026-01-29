module Colorls
  abstract class Layout
    def initialize(@contents : Array(FileInfo), @max_widths : Array(Int32), @screen_width : Int32)
    end

    def each_line(&block : Array(FileInfo), Array(Int32) ->)
      return if @contents.empty?
      chunks(chunk_size).each do |line|
        compacted = line.compact
        block.call(compacted, @max_widths)
      end
    end

    private abstract def chunk_size : Int32
    private abstract def chunks(size : Int32) : Array(Array(FileInfo?))

    # Binary search for optimal number of columns
    private def compute_chunk_size : Int32
      return 1 if @max_widths.empty?

      min_size = @max_widths.min
      max_chunks = Math.max(1, @screen_width // min_size)
      max_chunks = Math.min(max_chunks, @max_widths.size)
      min_chunks = 1

      loop do
        mid = ((max_chunks + min_chunks).to_f / 2).ceil.to_i

        size, col_widths = column_widths(mid)

        if min_chunks < max_chunks && col_widths.sum > @screen_width
          max_chunks = mid - 1
        elsif min_chunks < mid
          min_chunks = mid
        else
          @max_widths = col_widths
          return size
        end
      end
    end

    private abstract def column_widths(mid : Int32) : {Int32, Array(Int32)}
  end

  class SingleColumnLayout < Layout
    def initialize(contents : Array(FileInfo))
      super(contents, [1], 1)
    end

    private def chunk_size : Int32
      1
    end

    private def chunks(size : Int32) : Array(Array(FileInfo?))
      @contents.map { |item| [item.as(FileInfo?)] }
    end

    private def column_widths(mid : Int32) : {Int32, Array(Int32)}
      {1, [1]}
    end
  end

  class HorizontalLayout < Layout
    private def chunk_size : Int32
      compute_chunk_size
    end

    private def chunks(size : Int32) : Array(Array(FileInfo?))
      @contents.each_slice(size).to_a.map(&.map(&.as(FileInfo?)))
    end

    private def column_widths(mid : Int32) : {Int32, Array(Int32)}
      slices = @max_widths.each_slice(mid).to_a
      first_size = slices.first.size
      # Pad last slice to same size
      if slices.last.size < first_size
        (first_size - slices.last.size).times { slices.last << 0 }
      end
      # Transpose and get max of each column
      cols = Array.new(first_size) { |col_idx|
        slices.max_of { |row| col_idx < row.size ? row[col_idx] : 0 }
      }
      {mid, cols}
    end
  end

  class VerticalLayout < Layout
    private def chunk_size : Int32
      compute_chunk_size
    end

    private def chunks(size : Int32) : Array(Array(FileInfo?))
      columns = @contents.each_slice(size).to_a.map(&.map(&.as(FileInfo?)))
      # Pad last column
      if columns.size > 1 && columns.last.size < size
        (size - columns.last.size).times { columns.last << nil }
      end
      # Transpose columns into rows
      return columns if columns.empty?
      (0...size).map { |row_idx|
        columns.map { |col| row_idx < col.size ? col[row_idx] : nil }
      }.to_a
    end

    private def column_widths(mid : Int32) : {Int32, Array(Int32)}
      cs = (@max_widths.size.to_f / mid).ceil.to_i
      cols = @max_widths.each_slice(cs).to_a.map(&.max)
      {cs, cols}
    end
  end
end
