require "./ukkonen"
require "test/unit"
 
class TestSuffixTree < Test::Unit::TestCase
 
  def test_contains
    # is substring present in the given string
    assert_equal(1, SuffixTree.new("abc").contains?("a"))
    assert_equal(1, SuffixTree.new("abc").contains?("ab"))
    assert_equal(1, SuffixTree.new("abc").contains?("abc"))

    assert_equal(1, SuffixTree.new("abc").contains?("b"))
    assert_equal(1, SuffixTree.new("abc").contains?("bc"))
    assert_equal(1, SuffixTree.new("abc").contains?("c"))

    assert_equal(0, SuffixTree.new("abc").contains?(""))
    assert_equal(0, SuffixTree.new("abc").contains?("ac"))
    assert_equal(0, SuffixTree.new("abc").contains?("abcd"))

    assert_equal(1, SuffixTree.new("abbba").contains?("a"))
    assert_equal(1, SuffixTree.new("abbba").contains?("ab"))
    assert_equal(1, SuffixTree.new("abbba").contains?("abb"))

    assert_equal(1, SuffixTree.new("abbba").contains?("abbb"))
    assert_equal(1, SuffixTree.new("abbba").contains?("abbba"))
    assert_equal(1, SuffixTree.new("abbba").contains?("b"))

    assert_equal(1, SuffixTree.new("abbba").contains?("bb"))
    assert_equal(1, SuffixTree.new("abbba").contains?("bbb"))
    assert_equal(1, SuffixTree.new("abbba").contains?("bbba"))

    assert_equal(0, SuffixTree.new("abbba").contains?("bbbb"))
    assert_equal(0, SuffixTree.new("abbba").contains?("abba"))
    assert_equal(0, SuffixTree.new("abbba").contains?("bbbaa"))
  end

  def test_index_of
    # substring position in the given string
    assert_equal(0, SuffixTree.new("abracadabra").index_of("abracadabra"))
    assert_equal(1, SuffixTree.new("abracadabra").index_of("bra"))
    assert_equal(2, SuffixTree.new("abracadabra").index_of("racada"))

    assert_equal(3, SuffixTree.new("abracadabra").index_of("aca"))
    assert_equal(6, SuffixTree.new("abracadabra").index_of("dabra"))
    assert_equal(5, SuffixTree.new("abracadabra").index_of("adab"))

    assert_equal(-1, SuffixTree.new("book").index_of("oko"))
    assert_equal(1, SuffixTree.new("banana").index_of("anana"))
    assert_equal(3, SuffixTree.new("ananas").index_of("nas"))
  end
 
  def test_big_strings
    assert_equal(0, SuffixTree.new("atatatatatatatatatatatatatatatatatatatatatatata\
tatatatatatatatatatatatatatatatatatatatatatatatatatatatatatata").contains?("taa"))
    assert_equal(1, SuffixTree.new("atatatatatttttttttaaaaaatatatatatatttttaaattatata\
ttttttaaaaaaattttttttttttttttttttttttttttatatatatatatattatttta").contains?("atttta"))
    assert_equal(1, SuffixTree.new("In computer science, Ukkonen's algorithm is a linear-time, \
online algorithm for constructing suffix trees, proposed by Esko Ukkonen in 1995. The algorithm \
begins with an implicit suffix tree containing the first character of the string. Then it steps \
through the string adding successive characters until the tree is complete. This order addition \
of characters gives Ukkonen's algorithm its 'on-line' property; earlier algorithms proceeded \
backward from the last character. The naive implementation for generating a suffix tree requires \
O(n2) or even O(n3) time, where n is the length of the string. By exploiting a number of algorithmic \
techniques, Ukkonen reduced this to O(n) (linear) time, for constant-size alphabets, and O(n\log n) in general.").contains?("Ukkonen reduced this to"))
  end
end