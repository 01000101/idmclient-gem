# Needed for HTTP requests
require 'uri'
require 'net/http'
# Needed for JSON-RPC cookie management
require 'http-cookie'
# Needed for '{...}'.to_json
require 'json'
# Needed for request Id (UUID)
require 'securerandom'

# Test if this is executed in a ManageIQ / Cloudforms environment
MIQ_METHOD = !(defined?(MIQ_ID)).nil? || !(defined?(MIQ_URIx)).nil?
if MIQ_METHOD
  # Needed for MiqPassword.decrypt
  require 'miq-password'
end

class IDMClient
  attr_reader :http, :cookiejar, :uri_base, :uri_auth, :uri_data, :api_version

  def initialize(uri, ca_file='/etc/ipa/ca.crt', api_version='2.228')
    @uri_base = uri
    @uri_auth = URI("#{uri_base}/session/login_password")
    @uri_data = URI("#{uri_base}/session/json")
    @api_version = api_version
    # Prepare the connection
    @http = Net::HTTP.new(uri_auth.host, uri_auth.port)
    http.use_ssl = uri_auth.scheme == 'https'
    http.ca_file = ca_file
    http.set_debug_output($stdout)
    # Prepare cookie storage
    @cookiejar = HTTP::CookieJar.new
  end

  def authenticate(username, password)
    http.start {
      # Prepare the authentication request
      req = Net::HTTP::Post.new(uri_auth, 'Referer' => uri_base)
      req.form_data = {
        :user => username,
        # Cloudforms / ManageIQ - Decrypt password if necessary
        :password => (MIQ_METHOD && password.match(/^v\d\:\{.*\}$/)) ? MiqPassword.decrypt(password) : password
      }
      # Make the authentication request
      res = http.request req
      # Save the returned cookies
      res.get_fields('Set-Cookie').each { |value| cookiejar.parse(value, req.uri) }
      # Expecting an HTTP 200 response
      return res.code == '200'
    }
  end

  def call(method, args=Array.new, options=Hash.new)
    # Update options
    options['version'] = options['version'] || api_version
    # Start a connection
    http.start {
      # Prepare the data request
      req_id = SecureRandom.uuid
      req = Net::HTTP::Post.new(
        uri_data,
        'Content-Type' => 'application/json',
        'Referer' => uri_base,
        'Cookie' => HTTP::Cookie.cookie_value(cookiejar.cookies(uri_data)))
      req.body = {
        "method": method,
        "params": [args, options],
        "id": req_id,
      }.to_json
      # Make the data request and parse response
      res = http.request req
      data = JSON.parse(res.body)
      # Check for error
      if data['error']
        raise data['error']['message']
      end
      # Validate request Id and return results
      return (data['id'] == req_id) ? data['result']['result'] : nil
    }
  end
end
