require 'heroku/command/base'

require 'pty'

# handles Heroku's error and maintenance pages
class Heroku::Command::Pages < Heroku::Command::Base

  PAGES = {
    error:       'ERROR_PAGE_URL',
    maintenance: 'MAINTENANCE_PAGE_URL'
  }

  FOLDER = 'heroku_pages'

  LOCAL_FOLDER  = "public/#{FOLDER}"
  REMOTE_FOLDER = FOLDER

  # pages
  #
  #   Lists current Heroku pages
  #
  def index
    PAGES.each do |page, variable|
      display "#{page}: #{config[variable]}"
    end
  end

  # pages:open
  #
  #   Opens all Heroku pages in default application (may be OSX only)
  #
  def open
    PAGES.each do |page, variable|
      shell("open #{config[variable]}")
    end
  end

  # pages:upload
  #
  #   Uploads Heroku pages to an S3 bucket
  #
  def upload
    extract_and_verify_credentials

    run('which aws &>/dev/null')
    unless $?.success?
      error('Ensure `aws` binary is available (`[sudo] pip install awscli`)')
    end

    ENV['AWS_REGION']            = @region
    ENV['AWS_ACCESS_KEY_ID']     = @key
    ENV['AWS_SECRET_ACCESS_KEY'] = @secret

    run("aws s3 cp #{LOCAL_FOLDER} s3://#{@bucket}/#{REMOTE_FOLDER} --recursive --acl public-read --exclude '.*'")

    if $?.success?
      display("\e[92mUpload successful.\e[0m")
    else
      error("\e[91m\e[5mUpload failed.\e[0m")
    end
  end

  private

  # Lazily loads app's configuration variables
  def config
    @config ||= api.get_config_vars(app).body
  end

  # Extracts and verifies credentials from app's configuration variables
  def extract_and_verify_credentials
    @bucket = config['AWS_BUCKET']
    @region = config['AWS_REGION']
    @key    = config['AWS_KEY'] || config['AWS_ACCESS_KEY_ID']
    @secret = config['AWS_SECRET'] || config['AWS_SECRET_ACCESS_KEY']

    unless @bucket && @region && @key && @secret
      error('Ensure AWS_BUCKET, AWS_REGION, AWS_KEY and AWS_SECRET are set')
    end
  end

  # Runs given command using a pseudo-terminal to allow streaming of output
  #
  # Options:
  #   :out (io, defaults to $stdout)
  #
  def run(command, options = {})
    options = options.merge!(
      out: $stdout
    )

    buffer = StringIO.new

    PTY.spawn(command) do |output, input, pid|
      begin
        while !output.eof?
          chunk = output.readpartial(1024)
          buffer << chunk
          options[:out].print(chunk) if options[:out]
        end
      rescue Errno::EIO
      ensure
        Process.wait(pid)
      end
    end

    buffer.string
  end

end
