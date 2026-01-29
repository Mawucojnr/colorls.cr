require "./colorls"

exit_code = Colorls::Flags.new(ARGV).process
exit exit_code
