class TwitterController < ApplicationController
  def new    
  end

  def create
    @user = current_user
    @client = Twitter::Client.new(
                                  :oauth_token => "286016947-xE6LPmYJJpe3BwtVWlW9K45NyHvJ2xUCPq6I270O",
                                  :oauth_token_secret => "2DRhEyXne6EaVe5rLnfLV898A5qSWTQLNTnOiX0U"
                                  )
    @client.update(params[:post])
  end

  def show
  end
end
