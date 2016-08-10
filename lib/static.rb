class Static
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    # return ['200', {'Content-Type' => 'text/html'}, [env.to_s]]
    if env["PATH_INFO"].match(Regexp.new("/public/"))
      asset_match = env["PATH_INFO"].match(Regexp.new("/public/([^\.]+\.(.+))"))
      asset_path = asset_match[0][1..-1]
      asset_name = asset_match[1]
      asset_file_type = asset_match[2]

      #set mime type
      mime_type = case asset_file_type
      when "jpg"
        "image/jpeg"
      when "jpeg"
        "image/jpeg"
      when "txt"
        "text/html"
      when "text"
        "text/html"
      when "png"
        "image/png"
      when "zip"
        "application/zip"
      else
        raise "Oops! We think you got the file type wrong - what do you think?"
      end

      # find file
      begin
        f = File.open(asset_path, 'rb') { |file| file.read}
      rescue
        raise "Missing resource. You must be thinking of <i>another</i> localhost:3000..."
      end

      # return content
      ['200', {'Content-Type' => mime_type}, [f]]
    else
      @app.call(env)
    end

  end

end
