require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  test "should get teams all" do 
    get(:index)
    assert_response :success
    assert_select 'title', "Teams: All"
  end

  test "should get team 1" do
    get(:show, {'id' => "1"})
    assert_response :success
    assert_select 'title', "Teams: Atlanta Hawks"
  end

  test "should get team 2" do
    get(:show, {'id' => "2"})
    assert_response :success
    assert_select 'title', "Teams: Boston Celtics"
  end

  test "should get team 3" do
    get(:show, {'id' => "3"})
    assert_response :success
    assert_select 'title', "Teams: Charlotte Bobcats"
  end

  test "should get team 4" do
    get(:show, {'id' => "4"})
    assert_response :success
    assert_select 'title', "Teams: Chicago Bulls"
  end

  test "should get team 5" do
    get(:show, {'id' => "5"})
    assert_response :success
    assert_select 'title', "Teams: Cleveland Cavaliers"
  end

  test "should get team 6" do
    get(:show, {'id' => "6"})
    assert_response :success
    assert_select 'title', "Teams: Dallas Mavericks"
  end

  test "should get team 7" do
    get(:show, {'id' => "7"})
    assert_response :success
    assert_select 'title', "Teams: Denver Nuggets"
  end

  test "should get team 8" do
    get(:show, {'id' => "8"})
    assert_response :success
    assert_select 'title', "Teams: Detroit Pistons"
  end

  test "should get team 9" do
    get(:show, {'id' => "9"})
    assert_response :success
    assert_select 'title', "Teams: Golden State Warriors"
  end
 
  test "should get team 10" do
    get(:show, {'id' => "10"})
    assert_response :success
    assert_select 'title', "Teams: Houston Rockets"
  end

  test "should get team 11" do
    get(:show, {'id' => "11"})
    assert_response :success
    assert_select 'title', "Teams: Indiana Pacers"
  end

  test "should get team 12" do
    get(:show, {'id' => "12"})
    assert_response :success
    assert_select 'title', "Teams: Los Angeles Clippers"
  end

  test "should get team 13" do
    get(:show, {'id' => "13"})
    assert_response :success
    assert_select 'title', "Teams: Los Angeles Lakers"
  end

  test "should get team 14" do
    get(:show, {'id' => "14"})
    assert_response :success
    assert_select 'title', "Teams: Memphis Grizzlies"
  end

  test "should get team 15" do
    get(:show, {'id' => "15"})
    assert_response :success
    assert_select 'title', "Teams: Miami Heat"
  end


  test "should get team 16" do
    get(:show, {'id' => "16"})
    assert_response :success
    assert_select 'title', "Teams: Milwaukee Bucks"
  end

  test "should get team 17" do
    get(:show, {'id' => "17"})
    assert_response :success
    assert_select 'title', "Teams: Minnesota Timberwolves"
  end
  
 test "should get team 18" do
    get(:show, {'id' => "18"})
    assert_response :success
    assert_select 'title', "Teams: New Jersey Nets"
  end

  test "should get team 19" do
    get(:show, {'id' => "19"})
    assert_response :success
    assert_select 'title', "Teams: New Orleans Hornets"
  end

  test "should get team 20" do
    get(:show, {'id' => "20"})
    assert_response :success
    assert_select 'title', "Teams: New York Knicks"
  end

  test "should get team 21" do
    get(:show, {'id' => "21"})
    assert_response :success
    assert_select 'title', "Teams: Oklahoma City Thunder"
  end

  test "should get team 22" do
    get(:show, {'id' => "22"})
    assert_response :success
    assert_select 'title', "Teams: Orlando Magic"
  end

  test "should get team 23" do
    get(:show, {'id' => "23"})
    assert_response :success
    assert_select 'title', "Teams: Philadelphia 76ers"
  end

  test "should get team 24" do
    get(:show, {'id' => "24"})
    assert_response :success
    assert_select 'title', "Teams: Phoenix Suns"
  end

  test "should get team 25" do
    get(:show, {'id' => "25"})
    assert_response :success
    assert_select 'title', "Teams: Portland Trail Blazers"
  end

  test "should get team 26" do
    get(:show, {'id' => "26"})
    assert_response :success
    assert_select 'title', "Teams: Sacramento Kings"
  end
 
  test "should get team 27" do
    get(:show, {'id' => "27"})
    assert_response :success
    assert_select 'title', "Teams: San Antonio Spurs"
  end

  test "should get team 28" do
    get(:show, {'id' => "28"})
    assert_response :success
    assert_select 'title', "Teams: Toronto Raptors"
  end

  test "should get team 29" do
    get(:show, {'id' => "29"})
    assert_response :success
    assert_select 'title', "Teams: Utah Jazz"
  end

  test "should get team 30" do
    get(:show, {'id' => "30"})
    assert_response :success
    assert_select 'title', "Teams: Washington Wizards"
  end

end

=begin List of Teams from the database

1           Atlanta          Hawks          
2           Boston           Celtics        
3           Charlotte        Bobcats        
4           Chicago          Bulls          
5           Cleveland        Cavaliers      
6           Dallas           Mavericks      
7           Denver           Nuggets        
8           Detroit          Pistons        
9           Golden State     Warriors       
10          Houston          Rockets        
11          Indiana          Pacers         
12          Los Angeles      Clippers       
13          Los Angeles      Lakers         
14          Memphis          Grizzlies      
15          Miami            Heat           
16          Milwaukee        Bucks          
17          Minnesota        Timberwolves   
18          New Jersey       Nets           
19          New Orleans      Hornets        
20          New York         Knicks         
21          Oklahoma City    Thunder        
22          Orlando          Magic          
23          Philadelphia     76ers          
24          Phoenix          Suns           
25          Portland         Trail Blazers  
26          Sacramento       Kings          
27          San Antonio      Spurs          
28          Toronto          Raptors        
29          Utah             Jazz           
30          Washington       Wizards        

=end

