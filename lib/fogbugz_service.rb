require 'fogbugz'

class FogbugzService

  def initialize(api)
    @api = api
  end

  def implement(data)
    tell_fogbugz(:resolve, data, STATES[:implemented])
  end

  def fix(data)
    tell_fogbugz(:resolve, data, STATES[:fixed])
  end

  def complete(data)
    tell_fogbugz(:resolve, data, STATES[:completed])
  end

  def close(data)
    tell_fogbugz(:close, data)
  end

  def append_message(data)
    tell_fogbugz(:edit, data)
  end

  def invalid(data)
    # TODO: This silently ignores any bug id reference (#1234) without a
    # predicate; however I currently don't consider it a good idea to treat this
    # transparently as :reference
  end

  def reopen(data)
    tell_fogbugz(:reopen, data)
  end

  def resolve(data)
    tell_fogbugz(:resolve, data)
  end

  protected
  def tell_fogbugz(operation, data, status=nil)
    params = {"ixBug" => data[:case], "sEvent" => data[:message]}
    params["ixStatus"] = status if status
    @api.command(operation, params)
  end

  STATES = {:fixed => 2, :completed => 15, :implemented => 8}
end
