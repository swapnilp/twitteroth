class AuthController < ApplicationController
  before_filter :authenticate_user!, :except => [:access_token]
  skip_before_filter :verify_authenticity_token, :only => [:access_token]

  def welcome
    @user = current_user

#    oauth_consumer = OAuth::Consumer.new("apcRFXQ2JSQEWKd0yq46w", "QUyECFh0p86plDLbUVf20errxWoP0BYZ0wVMZ5pNCM",
#                                         :site => 'http://api.twitter.com',
#                                         :request_endpoint => 'http://api.twitter.com',
#                                         :sign_in => true)
    #request_token = oauth_consumer.get_request_token
    #puts request_token.authorize_url
    
    @client = Twitter::Client.new(
                                  :oauth_token => "286016947-xE6LPmYJJpe3BwtVWlW9K45NyHvJ2xUCPq6I270O",
                                  :oauth_token_secret => "2DRhEyXne6EaVe5rLnfLV898A5qSWTQLNTnOiX0U"
                                  )
#    @client.update("Tweeting aasdasds Eriksdfsdf!")


#    Twitter.configure do |config|
#      config.oauth_token = session[:oauth_token]
#      config.oauth_token_secret = session[:oauth_token_secret]
#    end

#    client = Twitter::Client.new
#    client.update("asdasdasd");
#    @client_erik = Twitter::Client.new(
#                                       :oauth_token => session[:oauth_token],
#                                       :oauth_token_secret => session[:oauth_token_secret]
#                                       )
#    @client_erik.update("asdasd");
  end

  def authorize
    AccessGrant.prune!
    access_grant = current_user.access_grants.create({:client => application, :state => params[:state]}, :without_protection => true)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])
    
    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  def failure
    render :text => "ERROR: #{params[:message]}"
  end

  def user
    hash = {
      :provider => 'josh_id',
      :id => current_user.id.to_s,
      :info => {
         :email => current_user.email, # change if required
      }
    }

    render :json => hash.to_json
  end

  # Incase, we need to check timeout of the session from a different application!
  # This will be called ONLY if the user is authenticated and token is valid
  # Extend the UserManager session
  def isalive
    warden.set_user(current_user, :scope => :user)
    response = { 'status' => 'ok' }

    respond_to do |format|
      format.any { render :json => response.to_json }
    end
  end

  protected

  def application
    @application ||= Client.find_by_app_id(params[:client_id])
  end

end
