require "dotenv"
Dotenv.load

require 'json'
require 'openai'
require 'sqlite3'
require 'sqlite_vss'
require 'pdf-reader'


COMPLETIONS_MODEL = "text-davinci-003"
MODEL_NAME = "curie"
DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"

if !File.file?(ARGV[0])
    abort "DB does not exist. Aborting."
end

if ARGV[1].nil?
    abort "Please provide a question. Aborting."
end

db = SQLite3::Database.new("#{ARGV[0]}.db")
db.enable_load_extension(true)
SqliteVss.load(db)
db.enable_load_extension(false)

q = ARGV[1]

def get_embedding(page, openai)
    res = openai.embeddings(parameters: { model: DOC_EMBEDDINGS_MODEL, input: page })
    res['data'].first['embedding']
end

openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

query_embedding = get_embedding(q, openai).to_json

# puts "Query embedding: #{query_embedding}"

# db.execute('drop table vss_pages')
db.execute(%{create virtual table if not exists vss_pages using vss0( e(4096) )})

db.execute(%{delete from vss_pages})
db.execute("insert into vss_pages (rowid, e) select rowid, e from pages")

res = db.query(%{
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


answers = res.map do |row|
    row[0]
end


context = answers.join("\n\n")


p = "Summarize the below context data and also try to answer the given question.
Context:
#{context}
Question: #{q}"

puts p

puts "\n\n Answer:\n"

response = openai.completions(
    parameters: {
        model: COMPLETIONS_MODEL,
        prompt: p,
        max_tokens: 100,
    })

puts "=================================\n"

puts response['choices'].first['text'].strip


