import email
import email.utils
import email.header
import imaplib
import md5
import time

import re

InternalDate = re.compile(r'.*INTERNALDATE "'
        r'(?P<day>[ 0123][0-9])-(?P<mon>[A-Z][a-z][a-z])-(?P<year>[0-9][0-9][0-9][0-9])'
        r' (?P<hour>[0-9][0-9]):(?P<min>[0-9][0-9]):(?P<sec>[0-9][0-9])'
        r' (?P<zonen>[-+])(?P<zoneh>[0-9][0-9])(?P<zonem>[0-9][0-9])'
        r'"')

class MessageInfo(object):
  __oldestMessageSec = time.mktime([2027, 12, 31, 23, 59, 59, 0, 0, 0]) 
  __newestMessageSec = time.mktime([1970, 1, 1, 0, 0, 0, 0, 0, 0]) 
  __parseDates = True
  
  _NAME_CACHE = {}  
  
  def __init__(self): 
    self.__message_id = None
    self.__mailboxes = []
    self.is_from_me = False
    self.is_to_me = False
    
    self.__parsed_name_address = {}
  
  def PopulateField(self, name, value):
    if name == "UID": self.__uid = value
    elif name == "RFC822.SIZE": self.size = int(value)
    elif name == "FLAGS": self.__flags = value
    elif name == "INTERNALDATE":
      self.__date_string = value

      if MessageInfo.__parseDates:
        self.__date_tuple = \
            imaplib.Internaldate2tuple('INTERNALDATE "%s"' % value)
        
        self.__date_sec = time.mktime(self.__date_tuple)
        if self.__date_sec > MessageInfo.__newestMessageSec:
          MessageInfo.__newestMessageSec = self.__date_sec
        if self.__date_sec < MessageInfo.__oldestMessageSec:
          MessageInfo.__oldestMessageSec = self.__date_sec
      
    elif name == "RFC822.HEADER": 
        self.headers = email.message_from_string(value)
    else: raise AssertionError("unknown field: %s" % name)

  def GetMessageId(self):
    if not self.__message_id:
      d = md5.new()
      d.update(str(self.size))
      d.update(self.__date_string)
      self.__message_id = d.digest()
    return self.__message_id

  def AddMailbox(self, mailbox):
    self.__mailboxes.append(mailbox)

  def GetDate(self):
    return self.__date_tuple
  
  def GetSender(self):
    return self._GetNameAddress("from")

  def GetListId(self):
    (name, address) = self._GetNameAddress("list-id")
    # Don't use the name part of the list-id header, it tends to be overly 
    # descriptive (i.e. too long)
    return address, address
    
  def GetRecipients(self):
    tos = self.GetHeaderAll('to')
    ccs = self.GetHeaderAll('cc')
    resent_tos = self.GetHeaderAll('resent-to')
    resent_ccs = self.GetHeaderAll('resent-cc')
    all_recipients = email.utils.getaddresses(
        tos + ccs + resent_tos + resent_ccs)
    
    # Cleaned up and uniquefied
    recipients_map = {}
    
    for name, address in all_recipients:
      if address:
        name, address = self._GetCleanedUpNameAddress(name, address)
        recipients_map[address] = name
    
    return [(name, address) for address, name in recipients_map.items()]

  def _GetNameAddress(self, header):
    if not header in self.headers:
      return None, None
      
    if header not in self.__parsed_name_address:
      header_value = self.GetHeader(header)
      header_value = header_value.replace("\n", " ")
      header_value = header_value.replace("\r", " ")
      name, address = email.utils.parseaddr(header_value)
      
      if address:
        name, address = self._GetCleanedUpNameAddress(name, address)
        
      self.__parsed_name_address[header] = name, address
      
    return self.__parsed_name_address[header]

  _PLUS_ADDRESS_RE = re.compile("\+.*@")

  def GetHeader(self, name):
    return self._GetDecodedValue(self.headers[name])
  
  def GetHeaderAll(self, name):
    values = self.headers.get_all(name, [])
    return [self._GetDecodedValue(value) for value in values]

  def _GetDecodedValue(self, value):
    try:
      pieces = email.header.decode_header(value)
      unicode_pieces = \
          [unicode(text, charset or "ascii") for text, charset in pieces]
      return u"".join(unicode_pieces)
    except LookupError:
      # Ignore bogus encodings
      return value
    except UnicodeDecodeError:
      # Ignore mis-encoded data
      return value

  def _GetCleanedUpNameAddress(self, name, address):
    address = address.lower()
    address = MessageInfo._PLUS_ADDRESS_RE.sub("@", address)
    
    if name == "No Description Available":
      name = None
    
    cache = MessageInfo._NAME_CACHE
    
    if address in cache:
      if name:
        cache[address][name] = cache[address].get(name, 0) + 1
      
      # TODO(mihaip): cache max and compare with updated key and re-compute if
      # necessary, instead of re-calculating every time
      popular_name_pair = \
          max(cache[address].items(), key=lambda pair: pair[1])
      name = popular_name_pair[0]
    elif name:
        cache[address] = {}
        cache[address][name] = 1
    else:
      name = address
    
    return name, address

  def GetDateRange():
    return [MessageInfo.__oldestMessageSec, MessageInfo.__newestMessageSec]
  GetDateRange = staticmethod(GetDateRange)
  
  def SetParseDate(parseDates):
    MessageInfo.__parseDates = parseDates
  SetParseDate = staticmethod(SetParseDate)
  
  def __str__(self):
    return "%s (size: %d, date: %s)" % (
        self.GetHeader("subject"), self.size, self.__date_string)