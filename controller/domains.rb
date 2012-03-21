#
# Controller for Domains
#

# TODO: adding a domain could be nice !
#
class Domains < MainController
  
  def index
    @title = 'Domains'

    # Get params, filtering ou nil and turning them to symbol
    sb = request.params['sortby'].nil? ? :name : request.params['sortby'].to_sym
    od = request.params['order'].nil? ? :asc : request.params['order'].to_sym

    # Check that the symbol obtained is valid
    sb = :name unless [:type, :content, :ttl].include? sb
    od = :asc unless :desc == od

    if (:desc == od) then
      Ramaze::Log.info("Sorting by #{sb} desc")
      @domains = paginate(Domain.order(sb).reverse.all)
    else
      Ramaze::Log.info("Sorting by #{sb} asc")
      @domains = paginate(Domain.order(sb).all)
    end
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

    # Get params, filtering ou nil and turning them to symbol
    sb = request.params['sortby'].nil? ? :name : request.params['sortby'].to_sym
    od = request.params['order'].nil? ? :asc : request.params['order'].to_sym

    # Check that the symbol obtained is valid
    sb = :name unless [:type, :content, :ttl].include? sb
    od = :asc unless :desc == od

    if (:desc == od) then
      Ramaze::Log.info("Sorting by #{sb} desc")
      @records = paginate(@domain.records_dataset.order(sb).reverse.all)
    else
      Ramaze::Log.info("Sorting by #{sb} asc")
      @records = paginate(@domain.records_dataset.order(sb).all)
    end
  end

  private

  def render_sidebar
    render_partial :sidebar
  end
end
