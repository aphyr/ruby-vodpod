module Vodpod
  class RecordSet < Array
    # An Array, with an extra method #total which returns the total number of
    # records available for the query which generated this recordset.

    def initialize(connection, klass, results)
      @total = results['total']
      replace(results['results'].map { |result|
        klass.new connection, result
      })
    end

    def total
      @total
    end
  end
end
