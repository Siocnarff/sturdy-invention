class Api::V1::DocumentController < ApplicationController
  def ask
    answer = Document.new.ask_book(params[:query])
    render json: answer
  end
end
