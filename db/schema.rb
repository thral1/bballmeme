# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100401114205) do

  create_table "articles", :force => true do |t|
    t.string   "url",                       :limit => 350
    t.integer  "num_visitors_per_month"
    t.integer  "num_backward_links"
    t.integer  "length"
    t.datetime "publication_date"
    t.integer  "rss_feed_level"
    t.string   "teams_mentioned"
    t.integer  "user_vote_score"
    t.string   "publication"
    t.integer  "writer_score"
    t.integer  "publication_score"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "publication_name"
    t.string   "author"
    t.string   "rss_description",           :limit => 2000
    t.integer  "num_comments"
    t.float    "score"
    t.integer  "site_ranking"
    t.string   "players_mentioned"
    t.integer  "article_rank"
    t.integer  "human_rank"
    t.boolean  "hide"
    t.integer  "age"
    t.integer  "zscore"
    t.string   "teams_associated_with_url"
    t.string   "article_type"
    t.string   "type"
    t.integer  "feed_score"
    t.integer  "num_teams_mentioned"
  end

  add_index "articles", ["url"], :name => "url"

  create_table "articles_links", :id => false, :force => true do |t|
    t.integer  "link_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles_links", ["article_id"], :name => "Index_2"
  add_index "articles_links", ["link_id"], :name => "Index_1"

  create_table "feedbacks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text"
    t.string   "submitter"
    t.string   "submitter_email"
  end

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.string   "name"
    t.integer  "relevance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "team"
    t.string   "sport"
    t.boolean  "active"
    t.string   "feed_type"
  end

  create_table "links", :force => true do |t|
    t.string   "url",        :limit => 350
    t.datetime "updated_at"
    t.integer  "article_id"
    t.datetime "created_at"
  end

  add_index "links", ["url"], :name => "index_links_on_url"

  create_table "teams", :force => true do |t|
    t.string   "city"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "urlinfos", :force => true do |t|
    t.integer  "num_monthly_visitors"
    t.integer  "site_ranking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",                  :limit => 350
  end

end
