#
# Controller for Domains
#
require 'awesome_print'
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

  def save
    # This method handles both new additions & updates
    # If domain_id is set, this is an update
    # Otherwise, it's a new domain
    id = request.params['domain_id']
    data = request.subset(:name, :type, :master)

    if !id.nil? and !id.empty?
      # Update
      domain = Domain[id]

      # Let's check the id provided is valid
      if domain.nil?
        flash[:error] = %q{Can not update this domain (I can't find it)}
        redirect_referrer
      end

      operation = "update"
    else
      # Create
      domain = Domain.new
      operation = "create"
    end

    begin
      domain.update(data)
      flash[:success] = "Domain '%s' %sd successfully" % [ data['name'], operation ]
      redirect(Domains.r(:records, domain.id))

    rescue => e
      Ramaze::Log.error(e) if Ramaze.options.mode == :live

      case e.wrapped_exception.error_number
      when 1062
        flash[:error] = "Domain '%s' already exists." % data['name']
      else
        flash[:error] = "Unable to %s domain %s" % [ operation, data['name'] ]
        flash[:error]<< "Got error %s : %s" % [ e.wrapped_exception.error_number, e.to_s ]
      end
      redirect_referrer
    end
  end

  def delete(id)
    d = Domain[id]
    if d.nil?
      flash[:error] = "Sorry, the domain ID '%s' doesn\'t exist" % d.id
    else
      flash[:success] = "Domain '%s' deleted successfully" % d.name
      d.destroy
      redirect_referrer
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
      @records = paginate(@domain.records_dataset.order(sb).reverse)
    else
      Ramaze::Log.info("Sorting by #{sb} asc")
      @records = paginate(@domain.records_dataset.order(sb))
    end
  end

end
