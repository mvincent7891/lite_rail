require 'json'
require 'byebug'

class Flash
  def initialize(req)
    flash_cookie = req.cookies["_rails_lite_app_flash"]
    @flash = flash_cookie ? JSON.parse(flash_cookie) : {}
  end

  def now
    @flash_now ||= {}
  end

  def [](key)
    @flash[key] || @flash_now[key]
  end

  def []=(key, val)
    @flash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    # What we're doing here is taking the current flash,
    # and storing it in a cookie in the response. That way, when
    # the client responds to us later, we have the data available again.
    return_hash = { path: "/", value: JSON(@flash)}
    res.set_cookie("_rails_lite_app_flash", return_hash)
  end
end
