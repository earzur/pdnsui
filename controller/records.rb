#
# Controller for Domains
#
class Records < MainController

  # This method handles updates & inserts
  # If a record_id is passed, then an update will be done
  # otherwise, it will be a create
  # 
  def save
    domain_id   = request.params['domain_id']
    record_id   = request.params['record_id']
    name        = request.params['name']
    content     = request.params['content']
    type        = request.params['type']

    if !domain_id.nil? and !name.empty? and !type.empty? and !content.empty?
      if record_id.nil?
        # Handling creates
        record = Record.new
      else
        # This is for updates
        record = Record[record_id]
      end
    else
      puts request.params
      flash[:error] = 'Unable to create record entry'
      redirect_referrer
    end

    # Now we can just update since record exists
    # It will be created in the database if this is not an update anyway
    flash[:success] = "Record #{name} created"
    record.update(:domain_id => domain_id,
                  :name => name,
                  :content => content,
                  :type => type);

    redirect_referrer
  end

  def edit(id)
    # TODO: check for valid id
  end
end
