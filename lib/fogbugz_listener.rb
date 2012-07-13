class FogbugzListener
  attr_reader :options

  def initialize(options={})
    @options = options
    @state = :invalid
    @actions = Hash.new {|h, k| h[k] = Array.new}
  end

  def fix
    @state = :fix
  end

  def implement
    @state = :implement
  end

  def reopen
    @state = :reopen
  end

  def close
    @state = :close
  end

  def reference
    @state = :reference
  end

  def complete
    @state = :complete
  end

  def case(bugid)
    @actions[@state] << bugid
  end

  def resolve
    @state = :resolve
  end

  def update_fogbugz(service)
    references = @actions.delete(:reference)

    message_header = ""
    message_header << "Commit: #{options[:sha1]}\n"
    message_header << "#{options[:commit_url]}\n" if options[:commit_url]

    message = message_header + "\n" + options[:message]

    if @actions.empty? then
      references.each do |bugid|
        service.append_message(:case => bugid, :message => message)
      end if references
    else
      message << "\n\nReferences " << references.map {|bugid| "case #{bugid}"}.join(", ") if references && !references.empty?
      @actions.each_pair do |action, bugids|
        bugids.each do |bugid|
          service.send(action, :case => bugid, :message => message)
        end
      end
    end
  end
end
