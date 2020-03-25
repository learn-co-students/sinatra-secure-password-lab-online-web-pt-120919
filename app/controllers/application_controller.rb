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
    #your code here
    user = User.new(username: params[:username], password: params[:password])
    
    if user.username != '' && user.save 
      redirect to('/login')
    else 
      redirect to('/failure')
    end
  end
  
  get '/withdraw' do 
    @user = User.find(session[:user_id])
    if @user.balance == 0 
      erb :failure
    else 
      erb :withdraw 
    end
  end
  
  post '/withdraw' do 
    @user = User.find(session[:user_id])
    if params[:amount].to_f > @user.balance 
      erb :failure 
    else 
      @user.balance = @user.balance - params[:amount].to_f
      @user.save
      erb :account
    end
  end
  
  get '/deposit' do 
    erb :deposit
  end
  
  post '/deposit' do 
    @user = User.find(session[:user_id])
    @user.balance = @user.balance + params[:amount].to_f
    @user.save
    erb :account
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    user = User.find_by(:username => params[:username])
 
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/account"
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
