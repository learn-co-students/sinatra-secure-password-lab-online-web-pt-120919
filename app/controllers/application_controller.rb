require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    user = User.new(username: params[:username], password: params[:password], balance: 0)
    if user.save && user.username != ""
      redirect "/login"
    else
      redirect "/failure"
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/account"
    else
      redirect "/failure"
    end
  end

  patch "/account/:id/update_balance" do
    user = User.find(params[:id])

    if params[:withdrawl] != "" && user.balance > params[:withdrawl].to_i
      new_balance = user.balance - params[:withdrawl].to_i
      user.update(balance: new_balance)
      @withdrawl = params[:withdrawl].to_i
      erb :withdrawl

    elsif params[:deposit] != ""
      new_balance = user.balance + params[:deposit].to_i
      user.update(balance: new_balance)
      @deposit = params[:deposit].to_i
      erb :deposit

    else
      redirect "/failure"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
