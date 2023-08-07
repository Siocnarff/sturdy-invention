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

def get_embedding(page, openai)
    res = openai.embeddings(parameters: { model: DOC_EMBEDDINGS_MODEL, input: page })
    res['data'].first['embedding']
end

def open_db(file_name)
    db = SQLite3::Database.new("#{file_name}.db")
    db.results_as_hash = true
    db.enable_load_extension(true)
    SqliteVss.load(db)
    db.enable_load_extension(false)
    db.execute(%{create table if not exists pages ( data text, e blob )})
    db.execute(%{create unique index if not exists pages_data_indx on pages(data)})
    db.execute(%{create virtual table if not exists vss_pages using vss0( e(4096) )})
    db
end

def store_page_with_embedding(page, embedding, db)
    db.query(%{insert into pages (data, e) values (?, ?) on conflict(data) do update set e=excluded.e}, [page, embedding.to_json])
end

begin
    reader = PDF::Reader.new(ARGV[0])
rescue
    abort "Error reading file. Aborting."
end

clean_pages = reader.pages.map do |page|
    page.text.strip
end

clean_pages = clean_pages.filter do |page|
    puts page.length
    page.length > 300
end

puts "Got #{clean_pages.length} pages"

openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

db = open_db(ARGV[0])
clean_pages.each do |page|
    embedding = get_embedding(page, openai)
    store_page_with_embedding(page, embedding, db)
end

puts "Done."





