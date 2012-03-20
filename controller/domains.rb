#
# Controller for Domains
#
class Domains < MainController
  
  def index
    @title = 'Domains'
    @domains = Domain
    @sidebar = render_sidebar
  end

  def edit(id)
    @domain = Domain[id]
    if @domain.nil?
      flash[:error] = 'sorry, this domain doesn\'t exist'
      redirect_referrer
    end
    @title = "#{@domain.name} domain"
    @sidebar = render_sidebar
  end

  def records(id)
    @domain = Domain[id]
    if @domain.nil?
      flash[:error] = 'sorry, this domain doesn\'t exist'
      redirect_referrer
    end
    @records = paginate(@domain.records)
    @sidebar = render_sidebar
  end

  private

  def render_sidebar
    render_partial :sidebar
  end
end
