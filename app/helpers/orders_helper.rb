module OrdersHelper  
  def signature(base_string, consumer_secret)
   secret="#{escape(consumer_secret)}"
   Base64.encode64(HMAC::SHA1.digest(secret,base_string)).chomp.gsub(/\n/,'')
 end
  def escape(value)
    CGI.escape(value.to_s).gsub("%7E", '~').gsub("+", "%20")
  end 

#def decode64(str)
#  str.unpack("m")[0]
#end
#
#def decode_b(str)
#  str.gsub!(/=\?ISO-2022-JP\?B\?([!->@-~]+)\?=/i) {
#    decode64($1)
#  }
#  str = Kconv::toeuc(str)
#  str.gsub!(/=\?SHIFT_JIS\?B\?([!->@-~]+)\?=/i) {
#    decode64($1)
#  }
#  str = Kconv::toeuc(str)
#  str.gsub!(/\n/, ' ')
#  str.gsub!(/\0/, '')
#  str
#end
#
#def encode64(bin)
#  [bin].pack("m")
#end
#
#def b64encode(bin, len = 60)
#  encode64(bin).scan(/.{1,#{len}}/o) do
#    print $&, "\n"
#  end
#end
end