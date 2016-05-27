# MiniUri
# Author: Alex Pilon
# Email: apilo088@gmail.com
# Security considerations drawn from
# https://tools.ietf.org/html/rfc2104
# https://tools.ietf.org/html/rfc4868
# https://tools.ietf.org/html/rfc6234

require 'openssl'
require 'base62'

module MiniUri

  DELIMITER = '-'
  HMAC_SIZE = 16 # bytes
  DIGEST = OpenSSL::Digest.new('sha256')

  attr_reader :id

  def MiniUri.included(klass)
    klass.extend(ClassMethods)
  end

  def MiniUri.hmac(message, secret, n = HMAC_SIZE)
    raise ArgumentError, "truncated hmacs should not be less than 10 bytes" if n > 32 || n < 10
    # generate a 256 bit (32 byte) hmac, then truncate it to n bytes
    hmac_truncated = OpenSSL::HMAC.digest(DIGEST, secret, message)[0, n]
    # convert raw bytes to hex string (which doubles the size because of 2's complement)
    # then convert to an integer, to be encoded finally to a base62 string
    Digest::hexencode(hmac_truncated).hex.base62_encode
  end

  def to_muri(int_id = id)
    raise ArgumentError, "id should be an Integer" unless int_id.is_a?(Integer)
    encoded_id = int_id.base62_encode
    encoded_id + DELIMITER + MiniUri.hmac(self.class.name + encoded_id, ENV["MINI_URI_SECRET"])
  end

  module ClassMethods
    def muri_to_id(mini_uri)
      raise ArgumentError, "mini_uri should be a String" unless mini_uri.is_a?(String)
      args = mini_uri.strip.split(DELIMITER)
      return nil if args.length != 2
      encoded_id, expected_hmac = args
      if expected_hmac == MiniUri.hmac(self.name + encoded_id, ENV["MINI_URI_SECRET"])
        encoded_id.base62_decode
      end
    end
  end
end
