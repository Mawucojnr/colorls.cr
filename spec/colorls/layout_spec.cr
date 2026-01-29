require "../spec_helper"

# Helper to create minimal FileInfo objects for layout tests
private def make_test_file(name : String) : Colorls::FileInfo
  # Use the spec directory as parent, create temp files
  Colorls::FileInfo.new(name: name, parent: __DIR__, path: File.join(__DIR__, "../spec_helper.cr"), link_info: false)
end

describe Colorls::SingleColumnLayout do
  it "yields one item per line" do
    items = [make_test_file("a"), make_test_file("b"), make_test_file("c")]
    lines = [] of Array(Colorls::FileInfo)
    layout = Colorls::SingleColumnLayout.new(items)
    layout.each_line { |line, _| lines << line }
    lines.size.should eq(3)
    lines.each(&.size.should(eq(1)))
  end

  it "handles empty contents" do
    layout = Colorls::SingleColumnLayout.new([] of Colorls::FileInfo)
    count = 0
    layout.each_line { |_, _| count += 1 }
    count.should eq(0)
  end
end

describe Colorls::HorizontalLayout do
  it "creates multi-column layout" do
    items = (1..6).map { |i| make_test_file("file#{i}") }.to_a
    widths = items.map { |_| 15 }
    layout = Colorls::HorizontalLayout.new(items, widths, 80)
    lines = [] of Array(Colorls::FileInfo)
    layout.each_line { |line, _| lines << line }
    lines.size.should be > 0
    # With 80 width and 15 per item, should fit multiple per line
    lines.first.size.should be > 1
  end
end

describe Colorls::VerticalLayout do
  it "creates multi-column layout" do
    items = (1..6).map { |i| make_test_file("file#{i}") }.to_a
    widths = items.map { |_| 15 }
    layout = Colorls::VerticalLayout.new(items, widths, 80)
    lines = [] of Array(Colorls::FileInfo)
    layout.each_line { |line, _| lines << line }
    lines.size.should be > 0
  end

  it "respects narrow width" do
    items = (1..6).map { |i| make_test_file("file#{i}") }.to_a
    widths = items.map { |_| 15 }
    layout = Colorls::VerticalLayout.new(items, widths, 20)
    lines = [] of Array(Colorls::FileInfo)
    layout.each_line { |line, _| lines << line }
    # Narrow width should produce more lines (fewer columns)
    lines.size.should be >= 3
  end

  it "handles single item" do
    items = [make_test_file("solo")]
    widths = [10]
    layout = Colorls::VerticalLayout.new(items, widths, 80)
    lines = [] of Array(Colorls::FileInfo)
    layout.each_line { |line, _| lines << line }
    lines.size.should eq(1)
  end
end
