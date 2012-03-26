class Utils < MainController

  # For this to work, the user running the application
  # must be in the pdns group
  def notify_slaves
    flash[:info] = 'This is not implemented yet :('
    redirect_referrer
  end
end


