RSpec.describe("Article Mutation テスト") do
  describe "Article データを登録する" do
    let(:user) { FactoryBot.create(:user) }
    let(:article_category) { FactoryBot.create(:article_category) }
    let(:article) do
      FactoryBot.attributes_for(:article, article_category_id: get_global_key("ArticleCategory", article_category.id))
    end

    let(:mutation) do
      %(mutation {
        createArticle(input: {
          title: "#{article[:title]}"
          body: "#{article[:body]}"
          thumnailUrl: "#{article[:thumnail_url]}"
          publicDate: "#{article[:public_date]}"
          articleCategoryId: "#{article[:article_category_id]}"
          isPublic: #{article[:is_public]}
          justCreated: #{article[:just_created]}
          slag: "#{article[:slag]}"
          tags: #{article[:tags]}
          isDeleted: #{article[:is_deleted]}
        }) {
            articleEdge {
          node {
              id
              title
              body
              thumnailUrl
              publicDate
              isPublic
              justCreated
              slag
              tags
              isDeleted
              }
            }
          }
        }
      )
    end

    subject(:result) do
      context = { user: user }
      SoulsApiSchema.execute(mutation, context: context).as_json
    end

    it "return Article Data" do
      begin
        a1 = result.dig("data", "createArticle", "articleEdge", "node")
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(
        include(
          "id" => be_a(String),
          "title" => be_a(String),
          "body" => be_a(String),
          "thumnailUrl" => be_a(String),
          "publicDate" => be_a(String),
          "isPublic" => be_in([true, false]),
          "justCreated" => be_in([true, false]),
          "slag" => be_a(String),
          "tags" => be_all(String),
          "isDeleted" => be_in([true, false])
        )
      )
    end
  end
end
