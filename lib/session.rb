require 'json'
require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    # does req.cookies automatically only get value of my return hash?
    req_cookie = req.cookies["_rails_lite_app"]
    # if the cookie has been set, parse it, otherwise set
    # to empty hash
    @internal_hash = req_cookie ? JSON.parse(req_cookie) : {}

  end

  def [](key)
    @internal_hash[key]
  end

  def []=(key, val)
    @internal_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    # What we're doing here is taking the current state of the session,
    # and storing it in a cookie in the response. That way, when
    # the client responds to us later, we have the data available again.
    return_hash = { path: "/", value: JSON(@internal_hash)}
    res.set_cookie("_rails_lite_app", return_hash)
  end
end
