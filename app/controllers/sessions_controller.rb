class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']

    @current_user = User.find_by(uid: auth_hash[:uid], name: auth_hash[:name], provider: 'github')
    if @current_user
      flash[:success] = "Welcome back #{@current_user.name}"
      redirect_to user_path(@current_user.id)
    else
      #try to make a new user
      @current_user = User.build_from_github(auth_hash)
      if @current_user.save
        flash[:success] = "Welcome #{@current_user.name}"
        redirect_to edit_user_path(@current_user.id)
        #would you like to register as a merchant?
      else
        flash[:error] = "Could not create account: #{@current_user.errors.messages}"
        redirect_to root_path
        return
      end
    end

    session[:user_id] = @current_user.id

  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Bye!"
    redirect_to root_path
  end
end
