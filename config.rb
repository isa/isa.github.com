require 'htmlentities'
require "redcarpet"
require 'find'
require 'date'
require 'rack/codehighlighter'

class Article
   attr_reader :title, :link, :date

   def initialize(title, link, date)
      @title = title
      @link = link
      @date = date
   end

   def title
      HTMLEntities.new.encode(@title)
   end
end

helpers do
   def create_articles_list
      articles = []
      Dir.glob("./source/20*/**/*.*").each do |file|
         content = File.open(file, "r").read
         title = /<header>(.*)<\/header>/i.match(content)[1]
         date = /<p class="date">&rsaquo; (.*)<\/p>/i.match(content)[1]
         link = /.\/source(.*).html.markdown/i.match(file)[1] + '/'
         articles.push(Article.new(title, link, date))
      end
      articles.sort_by { |a| [-DateTime.parse(a.date).to_time.to_i, a.title] }
   end
end

page "/articles*", :layout => :articles_layout

set :markdown, :layout_engine => :erb, :pretty => true
set :markdown_engine, Middleman::CoreExtensions::FrontMatter::RedcarpetTemplate

use Rack::Codehighlighter,
   :ultraviolet,
   :theme => "idle",
   :lines => false,
   :element => "pre",
   :pattern => /\A:::([-_+\w]+)\s*\n/,
   :logging => false

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
  activate :directory_indexes
end
