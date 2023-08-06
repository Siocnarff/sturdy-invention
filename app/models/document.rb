class Document < ApplicationRecord
    COMPLETIONS_MODEL = "text-davinci-003"
    MODEL_NAME = "curie"
    DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"

    def initialize x
        @root = Rails.root.to_s
        Dotenv.load("#{@root}/config/environtment/.env")
        @db = SQLite3::Database.new "#{@root}/scripts/cyberjutsu.pdf.db"
        @db.enable_load_extension(true)
        SqliteVss.load(@db)
        @db.enable_load_extension(false)
        @db.execute(%{create virtual table if not exists vss_pages using vss0( e(4096) )})
        @shem = "Summarize the below context data and also try to answer the given question using the context info."
        @openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    end

    def get_embedding text
        res = @openai.embeddings(parameters: { model: DOC_EMBEDDINGS_MODEL, input: text })
        res['data'].first['embedding']
    end

    def find_relevant_pages query 
        query_embedding = get_embedding(query).to_json
        pages = @db.query(%{
            with matches as (
              select rowid, distance
              from vss_pages
              where vss_search(
                e, ?
              )
              order by distance asc
              limit 6
            )
            select
              pages.data, matches.distance
            from matches
            left join pages on pages.rowid = matches.rowid}, query_embedding)
        pages.map do |row| row[0] end
    end

    def ask_book query
        begin
            pages = find_relevant_pages(query)
            p = "#{@shem}\n Context: #{pages.join('\n')}\n Query: #{query}"
            response = begin  @openai.completions(
                parameters: {
                    model: COMPLETIONS_MODEL,
                    prompt: p,
                    max_tokens: 200,
                })
            end
            {:answer => response['choices'].first['text'].strip}.to_json
        rescue
            {:answer => "Sorry, I am struggeling to answer that. Try again, and perhaps word it a bit differently?"}.to_json
        end
    end
end
