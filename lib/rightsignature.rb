require 'httparty'
require 'xml-fu'
require 'oauth'
require 'rightsignature/errors'
require 'rightsignature/helpers/normalizing'
require 'rightsignature/document'
require 'rightsignature/template'
require 'rightsignature/account'
require 'rightsignature/connection/oauth_connection'
require 'rightsignature/connection/token_connection'
require 'rightsignature/connection'

XmlFu.config.symbol_conversion_algorithm = :none
