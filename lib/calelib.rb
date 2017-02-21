require 'bundler'

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

# Google Calendar class
class GCal

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
    "calendar-ruby-quickstart.yaml")
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
#SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id   = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer  = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id     = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
      "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: 
        user_id, 
        code: code, 
        base_url: OOB_URI
      )
    end
    credentials
  end

  # Instantiate Google Calendar class
  #
  # @param [Fixnum] id Google Calendar id
  def initialize(id)
    # Initialize the API
    @service                = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization  = authorize
    @calendar_id            = id
  end

  # Get info from Google Calendar
  #
  # @param [?] param 
  def list_events(param)
    response = @service.list_events(@calendar_id, param)
  end

  # Send query to Google Calendar
  #
  # @param [Hash] param query
  def insert_event(param)
    @service.insert_event(@calendar_id, Google::Apis::CalendarV3::Event.new(param))
  end

  # Send 終日 query to Google Calendar
  #
  # @param [DateTime] date date
  def insert_whole_day(date, summary:nil, description:nil,time_zone:nil)
    insert_event(
      summary:summary, 
      description:description, 
      start:{
        date: date.to_s[/(.+)T/, 1],
        time_zone: time_zone
      },
      end:{
        #date_time: _end.iso8601,
        date: (date+1).to_s[/(.+)T/, 1],
        time_zone: time_zone
      }
    )
  end

end
