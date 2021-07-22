class Article < ActiveRecord::Base
  belongs_to :user
  belongs_to :article_category
end
