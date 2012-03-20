module Ramaze
  module Helper
    module SideBar
      def self.generate(current=nil)
        # Get the domain name currently being returned but the Domain controller
        # If we're not called from a Domain action, set it to an empty String so
        # Ruby doesn't complain
        currentname = ( current.nil? ? "" : current.name)

        # Get a list of forward/reverse domains
        # TODO: make it clever, grab zons with recent serials first
        @forward_domains = Domain.filter(~(:name.like('%in-addr.arpa'))).limit(10)
        @reverse_domains = Domain.filter(:name.like('%in-addr.arpa')).limit(10)

        @sidebar = %q{ <ul class="nav nav-list"><li class="nav-header">Forward Zones</li> }

        # Display forward domains
        @forward_domains.each do |d|
          @sidebar << "<li#{ " class=\"active\"" if currentname.eql?(d.name) }>"
          @sidebar << Domains.a(d.name, :records, d.id) + "</li>"
        end

        # And click for more
        @sidebar << "<li><em><a href=\"#{Domains.r}\"><i class=\"icon-plus\"></i>more...</a></em></li>"

        # Display reverse domains
        @sidebar << "<li class=\"nav-header\">Reverse zones</li>"
        @reverse_domains.each do |d|
          @sidebar << "<li#{ " class=\"active\"" if currentname.eql?(d.name) }>"
          @sidebar << Domains.a(d.name, :records, d.id) + "</li>"
        end

        # And click for more
        @sidebar << "<li><em><a href=\"#{Domains.r}\"><i class=\"icon-plus\"></i>more...</a></em></li>"

        @sidebar << "</ul>"
      end
    end
  end
end
