class WelcomeController < ApplicationController
  def index
    redirect_to :show if current_user
  end

  def show
    render :show, locals: { current_user: current_user }
  end
end
