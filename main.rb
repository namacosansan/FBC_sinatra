# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'cgi'

set :method_override, true

helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end

  def ensure_title(title)
    return unless title.nil? || title.strip.empty?

    status 400
    @message = 'タイトルは必須です。'
    halt erb(:error)
  end
end

MEMO_FILE = 'memos.csv'

def load_memos
  return [] unless File.exist?(MEMO_FILE)

  memos = []
  CSV.foreach(MEMO_FILE, headers: true) do |row|
    memos << row.to_hash
  end
  memos
end

def save_memos(memos)
  CSV.open(MEMO_FILE, 'w') do |csv|
    csv << %w[title content]
    memos.each do |memo|
      csv << [memo['title'], memo['content']]
    end
  end
end

get '/memos' do
  @memos = load_memos
  erb :top
end

get '/memo_new' do
  erb :memo_new
end

post '/memos' do
  title = params[:title]&.strip
  params[:content]

  ensure_title(title)

  memos = load_memos
  memos << {
    'title' => params[:title],
    'content' => params[:content]
  }
  save_memos(memos)
  redirect '/memos'
end

get '/memos/:id' do
  memos = load_memos
  index = params[:id].to_i
  memo = memos[index]

  @id = index
  @title = memo['title']
  @content = memo['content']
  erb :memos
end

delete '/memos/:id' do
  memos = load_memos
  index = params[:id].to_i
  memos.delete_at(index)
  save_memos(memos)
  redirect '/memos'
end

get '/memos/:id/edit' do
  memos = load_memos
  index = params[:id].to_i
  memo = memos[index]

  @id = index
  @title = memo['title']
  @content = memo['content']
  erb :memo_edit
end

patch '/memos/:id' do
  index = params[:id].to_i
  title = params[:title]
  content = params[:content]

  ensure_title(title)

  memos = load_memos
  memos[index]['title'] = title
  memos[index]['content'] = content
  save_memos(memos)
  redirect '/memos'
end
