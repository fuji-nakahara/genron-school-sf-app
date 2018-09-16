module GenronSf
  module Models
    class Base
      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end
    end
  end
end
