
module ActionController
  module Routing
    class RouteSet
      def extract_request_environment(request)
        { :method => request.method, :hostname => request.domain.split('.').first }
      end
    end
    class Route
      alias_method :old_recognition_conditions, :recognition_conditions
      def recognition_conditions
        result = old_recognition_conditions
        result << "conditions[:hostname] === env[:hostname]" if conditions[:hostname]
        result
      end
    end
  end
end

