RSpec.describe("Article Mutation テスト") do
  describe "Article データを登録する" do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.attributes_for(:article) }

    let(:mutation) do
      %(mutation {
        createArticle(input: {
          title: "#{article[:title]}"
          body: "#{article[:body]}"
          category: "#{article[:category]}"
          tags: #{article[:tags]}
          slug: "#{article[:slug]}"
          published: #{article[:published]}
          isDeleted: #{article[:is_deleted]}
        }) {
            articleEdge {
          node {
              id
              title
              body
              category
              tags
              slug
              published
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
          "category" => be_a(String),
          "tags" => be_all(String),
          "slug" => be_a(String),
          "published" => be_in([true, false]),
          "isDeleted" => be_in([true, false])
        )
      )
    end
  end
end
