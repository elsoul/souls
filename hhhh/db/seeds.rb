require "./app"

Dir[File.expand_path("#{Rack::Directory.new('').root}/spec/factories/*.rb")]
  .each { |file| require file }

def create_user
  gimei = Gimei.name
  user =
    FactoryBot.create(
      :user,
      username: gimei.kanji,
      last_name: gimei.last.hiragana,
      first_name: gimei.first.hiragana,
      last_name_kanji: gimei.last.kanji,
      first_name_kanji: gimei.first.kanji,
      last_name_kana: gimei.last.katakana,
      first_name_kana: gimei.first.katakana,
      gender: gimei.gender
    )
  puts(user.to_json)
  return user.id if user
end

def create_article_category
  article_category = FactoryBot.create(:article_category)
  "Article Category Created!\n #{article_category.to_json}" if article_category
end

def create_article(user_id, article_category_id)
  article = FactoryBot.create(:article, user_id: user_id, article_category_id: article_category_id)
  "Article Created!\n #{article.to_json}" if article
end

%w[お知らせ 特集 レシピ].each do |name|
  puts ArticleCategory.create(name: name).to_json
end

10.times { create_user }

100.times do |_i|
  user_id = User.find(rand(5).to_i + 1).id
  article_category_id = ArticleCategory.find(rand(3).to_i + 1).id
  puts create_article(user_id, article_category_id)
end
