# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'cgi'

helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

# メモを保存するファイル
MEMO_FILE = 'memos.csv'

# メモを読み込む
def load_memos
  return [] unless File.exist?(MEMO_FILE)

  memos = []
  CSV.foreach(MEMO_FILE, headers: true) do |row|
    memos << { 'title' => row['title'], 'content' => row['content'] }
  end
  memos
end

# メモを保存する
def save_memos(memos)
  CSV.open(MEMO_FILE, 'w') do |csv|
    csv << %w[title content] # ヘッダー
    memos.each do |memo|
      csv << [memo['title'], memo['content']]
    end
  end
end

# Top画面
get '/' do
  @memos = load_memos # メモの一覧表示
  erb :top
end

# new_memo 入力画面
get '/new_memo' do
  erb :new_memo
end

# save_memo　メモの登録
post '/save_memo' do
  title = params[:title]&.strip # 空白の削除
  params[:content]

  if title.nil? || title.empty?
    status 400
    @message = 'タイトルは必須です。'
    return erb :error
  end

  memos = load_memos
  memos << {
    'title' => params[:title],
    'content' => params[:content]
  }
  save_memos(memos)
  redirect '/'
end

# show_memo　メモを表示する
get '/memos/:id' do
  memos = load_memos
  index = params[:id].to_i
  memo = memos[index]

  @id = index
  @title = memo['title']
  @content = memo['content']
  erb :show_memo
end

# deleteボタン
delete '/memos/:id' do
  memos = load_memos
  index = params[:id].to_i
  memos.delete_at(index)
  save_memos(memos)
  redirect '/'
end

# edit_memo
get '/memos/:id/edit' do
  memos = load_memos
  index = params[:id].to_i
  memo = memos[index]

  @id = index
  @title = memo['title']
  @content = memo['content']
  erb :edit_memo
end

patch '/memos/:id' do
  index = params[:id].to_i
  title = params[:title]&.strip
  content = params[:content]

  if title.nil? || title.empty?
    status 400
    @message = 'タイトルは必須です。'
    return erb :error
  end

  memos = load_memos
  memos[index]['title'] = title
  memos[index]['content'] = content
  save_memos(memos)
  # トップページに戻す
  redirect '/'
end
