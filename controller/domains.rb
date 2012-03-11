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
    @title = "#{@domain.name} domain"
  end
end
