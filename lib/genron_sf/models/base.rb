module GenronSf
  module Models
    class Base
      attr_reader :doc

      def initialize(doc, options = nil)
        @doc = doc
        post_initialize(options)
      end

      def post_initialize(options)
        # subclasses may override
      end
    end
  end
end
