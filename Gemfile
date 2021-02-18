source 'https://rubygems.org'

# Ruby 2.5.7
gem 'rails', '~> 5.2.4'

gem 'listen'
gem 'bootsnap'
# Support for databases and environment.
# Use 'sqlite3' for testing and development and mysql and postgresql
# for production.
#
# To speed up the 'git push' process you can exclude gems from bundle install:
# For example, if you use rails + mysql, you can:
#
# $ rhc env set BUNDLE_WITHOUT="development test postgresql"
#
group :development, :test do
#  gem 'pg'
#  gem 'minitest'
#  gem 'thor'
end

group :production, :postgresql do
  gem 'pg'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
# Use Bootstrap
gem 'bootstrap-sass', '~> 3'
gem 'autoprefixer-rails'
gem 'font-awesome-sass'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 2.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Updated to avoid vulnerabilities CVE-2019-5477 and GHSA-vr8q-g5c7-m54m (GitHub)
gem "nokogiri", ">= 1.11.0"

# Use HAML
gem 'haml'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
