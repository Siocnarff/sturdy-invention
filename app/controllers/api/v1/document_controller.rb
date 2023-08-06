class Api::V1::DocumentController < ApplicationController
  def ask
    answer = Document.new.ask_book(params[:query])
    render json: answer
  end
  
  def ask_what_to_ask
    question = Document.new.get_relevant_question()
    render json: question
  end

  def get_random_past_question
    question = Document.new.get_random_past_question()
    render json: question
  end
end
