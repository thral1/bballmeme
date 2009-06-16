require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  test "should paginate" do
    # example taken from http://docs.activestate.com/komodo/5.0/tutorial/railstut.html
    Article.delete_all
    35.times {|i| Article.create(:title => "title #{i}")}
    get :index
    assert_response :success
    assert_tag(:tag => 'div',
               :attributes => { :class => 'pagination'})
    assert_tag(:tag => 'span',
               :content => '&laquo; Previous',
               :attributes => { :class => 'disabled'})
    assert_tag(:tag => 'span',
               :content => '1',
               :attributes => { :class => 'current'})
    assert_tag(:tag => 'div',
               :attributes => { :class => 'pagination'},
               :child => { :tag => 'a',
                 :attributes => { :href => "/articles?page=4" },
                 :content => "4" })
  end

  test "should get about us" do
    get :aboutus
    assert_response :success
    assert_select 'title', "About Us"
  end 

  test "should get contact us" do
    get :contactus
    assert_response :success
    assert_select 'title', "Contact Us"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select 'title', "Help"
  end

  test "should get advertise" do
    get :advertise
    assert_response :success
    assert_select 'title', "Advertise"
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:articles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create article" do
    assert_difference('Article.count') do
      post :create, :article => { }
    end

    assert_redirected_to article_path(assigns(:article))
  end

  test "should show article" do
    get :show, :id => articles(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => articles(:one).id
    assert_response :success
  end

  test "should update article" do
    put :update, :id => articles(:one).id, :article => { }
    assert_redirected_to article_path(assigns(:article))
  end

  test "should destroy article" do
    assert_difference('Article.count', -1) do
      delete :destroy, :id => articles(:one).id
    end

    assert_redirected_to articles_path
  end
end
