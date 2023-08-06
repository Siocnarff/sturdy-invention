class Document < ApplicationRecord
    COMPLETIONS_MODEL = "text-davinci-003"
    MODEL_NAME = "curie"
    DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"

    def initialize x
        @root = Rails.root.to_s
        Dotenv.load("#{@root}/config/environments/.env")
        @db = SQLite3::Database.new "#{@root}/scripts/cyberjutsu.pdf.db"
        @db.enable_load_extension(true)
        SqliteVss.load(@db)
        @db.enable_load_extension(false)
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
              limit 3
            )
            select
              pages.data, matches.distance
            from matches
            left join pages on pages.rowid = matches.rowid}, query_embedding)
        pages.map do |row| row[0] end
    end

    def get_answer_from_openai p
        response = begin  @openai.completions(
            parameters: {
                model: COMPLETIONS_MODEL,
                prompt: p,
                max_tokens: 200,
            })
        end
        answer = response['choices'].first['text'].strip
end

    def ask_book query
        question = Question.find_by(q: query)
        if question
            question.update(:ask_count => question.ask_count + 1)
            return {:answer => question.a}
        end
        
        begin
            pages = find_relevant_pages(query)
            p = "#{@shem} \n\n Context: #{pages.join("\n\n")} \n\n Query: #{query}"
            answer = get_answer_from_openai(p)
            Question.create(:q => query, :a => answer, :ask_count => 1)
            {:answer => answer}
        rescue
            {:answer => "Sorry, I am struggeling to answer that. Try again, and perhaps word it a bit differently?"}
        end
    end

    def get_relevant_question 
        size = @db.query("select count(*) from pages").first.first
        query = "I list some pages below. Please tell me what would be a good question to ask about a book that has these pages inside it.\n\n"

        (1..2).each do |i|
            page_number = rand(1..size).to_i
            page = @db.query("select data from pages where rowid = ?", page_number).first.first
            page = page.gsub("\n", " ").strip
            query += "Page #{page_number}: #{page}\n\n"
        end
        
        query += "\n\n"
        query += "Question to ask:"

        {:question => get_answer_from_openai(query)}
    end
end
