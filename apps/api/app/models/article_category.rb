class ArticleCategory < ActiveRecord::Base
  has_many :article, dependent: :destroy
end
