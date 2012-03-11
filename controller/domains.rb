#
# Controller for Domains
#
class Domains < MainController
  
  def index
    @title = 'Domains'
    @domains = Domain
  end

  def edit(id)
    @domain = Domain[id]
    if @domain.nil?
      flash[:error] = 'sorry, this domain doesn\'t exist'
      redirect_referrer
    end
    @title = "#{@domain.name} domain"
  end

  def records(id)
    @domain = Domain[id]
    if @domain.nil?
      flash[:error] = 'sorry, this domain doesn\'t exist'
      redirect_referrer
    end
    @records = paginate(@domain.records)
  end
end
