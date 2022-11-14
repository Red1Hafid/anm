module ApplicationHelper
    def domainename
        return request.protocol()+request.host_with_port()+"/"
    end
end
