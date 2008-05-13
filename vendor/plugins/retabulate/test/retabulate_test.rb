require 'test/unit'
require 'lib/retabulate'

class RetabulateTest < Test::Unit::TestCase
	# Replace this with your real tests.
	def test_retabulate
		assert_equal("\t\thello world", Retabulate::retabulate("    hello world"))
	end
	def test_mixed
		assert_equal("\t\t\thello world", Retabulate::retabulate("\t  \thello world"))
	end
	def test_only_retab_leading_space
		assert_equal("hello  world", Retabulate::retabulate("hello  world"))
	end
	def test_blanks
		assert_equal("", Retabulate::retabulate(""))
		assert_equal(" ", Retabulate::retabulate(" "))
		assert_equal("\t", Retabulate::retabulate("  "))
	end
end
