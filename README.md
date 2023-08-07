# Ask A Book

## How to use the scripts to build your own embeddings for a pdf

1. add OPENAI_API_KEY = 'yourkey' to an .env file in the scripts folder
2. add the pdf you want to ask questions of in the scripts folder
3. run $ ruby ingest.rb pdf_name.pdf
4. run $ ruby answer.rb pdf_name.pdf "your question here"
    - note that you are giving the pdf name, not the generated db name
    - this will demonstrate the working of building a query based on your document pages, and sending it to openai for a response

## How to locally run server
1. generate embeddings for file, leave generated embeddings pdf in scripts folder
2. add BOOK_DB_FILE = 'your_book.pdf.db' to .env
3. run rails dev server + migrations etc as standard
