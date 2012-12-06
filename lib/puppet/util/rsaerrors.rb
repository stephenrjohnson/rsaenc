module RsaUtils
  class Error < StandardError ; end
  class EncryptionError < StandardError ; end
  class DecryptionError < StandardError ; end
  class KeyFileError    < StandardError ; end
  class WriteFileError  < StandardError ; end
  class FilterHostsError < StandardError ; end
  class DecryptDataError < StandardError ; end
end
