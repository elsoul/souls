module ArticleMethod
  def create_article(grpc_req, _unused_call)
    logger = Logger.new(STDOUT)
    firestore = Google::Cloud::Firestore.new
    article = firestore.col("articles").doc
    article.set({})
    data = firestore.col("articles").doc(article.document_id)
    article_hash = {
      id: article.document_id,
      user_id: grpc_req.user_id,
      title: grpc_req.title,
      body: grpc_req.body,
      thumnail_url: grpc_req.thumnail_url,
      public_date: grpc_req.public_date,
      is_public: grpc_req.is_public,
      tag: grpc_req.tag.to_a,
      created_at: Time.now.utc,
      updated_at: Time.now.utc
    }
    data.update article_hash
    res = Souls::CreateArticleReply.new(
      { article: article_hash }
    )
    logger.info res.article
    res
  rescue StandardError => error
    logger.debug error
  end

  def get_article(grpc_req, _unused_call)
    logger = Logger.new(STDOUT)
    article = Article.find(grpc_req.id)
    reply = JSON.parse(article.to_json)
    reply["created_at"] = article.created_at.to_s
    reply["updated_at"] = article.updated_at.to_s
    res = Souls::GetArticleReply.new(
      { article: Souls::Article.new(reply) }
    )
    logger.info res.article
    res
  rescue StandardError => error
    logger.debug error
  end

  def get_articles
    return enum_for(:get_articles) unless block_given?
    q = ::Article
    limit = 100
    q.limit(limit).each do |article|
      sleep(rand(0.01..0.3))
      Souls::Article.new article.to_proto
    end
  rescue StandardError => e
    fail!(:internal, :unknown, "Unknown error when listing Articles: #{e.message}")
  end

  def update_article(grpc_req, _unused_call); end

  def delete_article(grpc_req, _unused_call); end
end
