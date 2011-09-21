require 'find'
require 'date'
require 'uv'
# require 'rygments'
require 'rack/codehighlighter'

class Article
   attr_reader :title, :link, :date

   def initialize(title, link, date)
      @title = title
      @link = link
      @date = date
   end
end

helpers do
   def create_articles_list
      articles = []
      Dir.glob("./source/20*/**/*.slim").each do |file|
         content = File.open(file, "r").read

         title = /header (.*)/i.match(content)[1]
         date = /date.*&rsaquo; (.*)/i.match(content)[1]
         link = /.\/source(.*).html.slim/i.match(file)[1] + '/'

         articles.push(Article.new(title, link, date))
      end
      articles.sort_by { |a| [-DateTime.parse(a.date).to_time.to_i, a.title] }
   end
end

page "/articles*", :layout => :layout_article_list
page "/20*", :layout => :layout_entry
set :slim, :pretty => true

use Rack::Codehighlighter,
   :ultraviolet,
   :theme => "idle",
   :lines => false,
   :element => "pre",
   :pattern => /\A::([-_+\w]+)::\s*/,
   :logging => false

# use Rack::Codehighlighter,
#    :pygments,
#    :element => "pre",
#    :pattern => /\A::([-_+\w]+)::\s*/,
#    :logging => false

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
  activate :directory_indexes
end
