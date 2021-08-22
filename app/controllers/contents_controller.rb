class ContentsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def show
    @contents = Content.all
  end

  def create
    Learning.create(user_id: current_user.id, content_id: params[:id])
    @contents = Content.all
  end

  def destroy
    learning = Learning.find_by(user_id: current_user, content_id: params[:id])
    learning.destroy
    @contents = Content.all
  end

end
