ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true
  def assert_parsed_correct_number_comments( article , correct_number_of_comments )
    assert( article.num_comments == correct_number_of_comments , "Article: #{article.url} has #{correct_number_of_comments} comments, not #{article.num_comments}\n" ) 
  end

  #this is used for re-directed comment sites like ESPN, foxsports, cbssports.  There could be more comments added later
  def assert_parsed_greater_or_equal_than_the_number_comments( article , correct_number_of_comments )
    assert( article.num_comments >= correct_number_of_comments , "Article: #{article.url} has at least #{correct_number_of_comments} comments, not #{article.num_comments}\n" ) 
  end

  def assert_parsed_article_text_correctly( article, text )
    assert( article.text == text, "Article: #{article.url} was not parsed correctly\nparsed text: #{article.text.inspect}\n\n\ncorrect text: #{text.inspect}" )
  end


  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
