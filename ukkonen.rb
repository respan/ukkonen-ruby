require 'thread'
class SuffixTree
  attr_reader :root, :text, :nodes_count

  def initialize(text)
    @text = text
    @root = Node.new(nil, 0)
    @nodes_count = 1

    active = Suffix.new(@root, 0, -1)
    @text.length.times { |i| add_prefix(active, i) }
  end

  def contains?(str)
    index_of(str) != -1
  end

  def index_of(str)
    return -1 if str.length == 0

    index = -1
    node = @root

    i = 0
    while i < str.length
      return -1 if (node == nil || i == text.length)

      edge = node.find_edge(str[i])

      return -1 unless edge

      index = edge.begin_index - i
      i += 1

      (edge.begin_index + 1).upto(edge.end_index) do |j|
        break if i == str.length

        return -1 unless @text[j] == str[i]

        i += 1
      end

      node = edge.end_node
    end
    index
  end

  def dump_edges(queue = nil)
    if !queue
      print "\tEdge \tStart \tEnd \tSuf \tFirst \tLast \tString\n"
      queue = Queue.new

      queue << @root
      dump_edges(queue)
    else
      while !queue.empty?
        node = queue.pop
        node.edges.values.each do |edge|
          suffix_node = edge.end_node.suffix_node

          print "\t#{ edge.to_s }"
          print "\t#{ edge.start_node.to_s }"
          print "\t#{ edge.end_node.to_s }"
          print "\t#{ suffix_node ? suffix_node.to_s : '-1' }"
          print "\t#{ edge.begin_index }"
          print "\t#{ edge.end_index }\t"

          edge.begin_index.upto(edge.end_index) { |i| print @text[i] }
          print "\n"

          queue << edge.end_node# if edge.end_node
        end
      end
    end
  end

  private
  def add_suffix_link(node, suffix_node)
    node.suffix_node = suffix_node unless (node == nil || node == @root)
  end

  def add_prefix(active, end_index)
    last_parent_node = nil
    parent_node = nil

    while true
        edge = nil
        parent_node = active.origin_node
        if active.explicit?
          edge = active.origin_node.find_edge(@text[end_index])
          break if edge
        else
            edge = active.origin_node.find_edge(@text[active.begin_index])

            break if @text[edge.begin_index + active.span + 1] == @text[end_index]

            parent_node = edge.split(active, @text, @nodes_count)
            @nodes_count += 1
        end

        new_edge = Edge.new(end_index, @text.length - 1, parent_node, @nodes_count)
        @nodes_count += 1
        new_edge.insert(@text)
        add_suffix_link(last_parent_node, parent_node)
        last_parent_node = parent_node

        if active.origin_node == @root
            active.begin_index += 1
        else
            active.origin_node = active.origin_node.suffix_node
        end

        active.canonize(@text)
    end

    add_suffix_link(last_parent_node, parent_node)
    active.end_index += 1
    active.canonize(@text)
  end

  class Edge
    attr_reader :begin_index, :end_index, :start_node, :end_node

    def initialize(begin_index, end_index, start_node, nodes_count)
      @begin_index = begin_index
      @end_index = end_index
      @start_node = start_node
      @end_node = Node.new(nil, nodes_count)
    end

    def split(suffix, text, nodes_count)
      @start_node.delete_edge(text[@begin_index])
      new_edge = Edge.new(@begin_index, @begin_index + suffix.span, suffix.origin_node, nodes_count)
      new_edge.insert(text)
      new_edge.end_node.suffix_node = suffix.origin_node
      @begin_index += suffix.span + 1
      @start_node = new_edge.end_node
      insert(text)
      new_edge.end_node
    end

    def insert(text)
      @start_node.add_edge(text[@begin_index], self)
    end

    def span
      @end_index - @begin_index
    end

    def to_s
      end_node.to_s
    end
  end

  class Suffix
    attr_accessor :origin_node, :begin_index, :end_index

    def initialize(origin_node, begin_index, end_index)
      @origin_node = origin_node
      @begin_index = begin_index
      @end_index = end_index
    end

    def explicit?
      @begin_index > @end_index
    end

    def implicit?
      !explicit?
    end

    def span
      @end_index - @begin_index
    end

    def canonize(text)
      if implicit?
        edge = @origin_node.find_edge(text[@begin_index])

        while edge.span <= span
          @begin_index += edge.span + 1
          @origin_node = edge.end_node

          if @begin_index <= @end_index
            edge = edge.end_node.find_edge(text[@begin_index])
          end
        end
      end
    end
  end

  class Node
    attr_accessor :suffix_node
    attr_reader :edges, :name

    def initialize(suffix_node, nodes_count)
      @suffix_node = suffix_node
      @edges = Hash.new {}
      @name = nodes_count
    end

    def add_edge(i, edge)
      @edges[i] = edge
    end

    def delete_edge(i)
      @edges.delete(i)
    end

    def find_edge(i)
      @edges[i]
    end

    def to_s
      @name
    end
  end
end
