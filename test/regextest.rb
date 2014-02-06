bug_list = []

j = "stuff bugs: 34#52, :543, 25 65"

if( (j.downcase =~ /(issue|bug|case|id)s*(([ ,:;#-]*\d+)+)+/) != nil)
  if($2 != nil)
    print "Found bug(s) " + $2.inspect + "\n"
    bug_list = $2.scan(/(\d+)/)
  end
end

bug_list.each do |fb_bugzid|
  print "\nBug: " + fb_bugzid.to_s + "\n"
end
