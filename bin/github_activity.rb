#!/usr/bin/env ruby

require 'octokit'
require 'active_support/core_ext/numeric/time' # 1.day.ago
require 'active_support/core_ext/string' # truncate, strip_heredoc
require 'active_support/core_ext/time' # time zone support
require 'active_support/inflector/methods' # constantize

Time.zone = 'Eastern Time (US & Canada)'

GITHUB_HOST = 'https://git.innova-partners.com'

Octokit.configure do |c|
  c.api_endpoint  = "#{GITHUB_HOST}/api/v3/"
  c.access_token  = ENV['GITHUB_TOKEN']
end

SCREEN_WIDTH = `tput cols`.to_i
fail if SCREEN_WIDTH.zero?

class Event
  def initialize(data)
    @payload   = data.payload
    @repo      = data.repo
    @timestamp = data.created_at.in_time_zone.strftime '%a %I:%M%P'
  end

  def to_s
    <<-EOT.strip_heredoc
      #{timestamp}   #{type}
      #{content}
      #{link}

    EOT
  end

  private

  attr_reader :payload, :repo, :timestamp

  %i(type content link).each do |method|
    define_method(method) { raise NotImplementedError }
  end
end

class IssuesEvent < Event
  def type
    "#{payload.action} an issue"
  end
  def content
    payload.issue.title.truncate SCREEN_WIDTH
  end
  def link
    payload.issue.html_url
  end
end

class PullRequestEvent < IssuesEvent
  def type
    "#{payload.action} a pull request"
  end
  def content
    payload.pull_request.title.truncate SCREEN_WIDTH
  end
  def link
    payload.pull_request.html_url
  end
end

class Comment < Event
  def type
    'comment'
  end
  def content
    payload.comment.body.gsub(/\r|\n/, ' ').truncate SCREEN_WIDTH
  end
  def link
    payload.comment.html_url
  end
end
IssueCommentEvent             = Class.new(Comment)
PullRequestReviewCommentEvent = Class.new(Comment)

module LinkToRepo
  def link
    "#{GITHUB_HOST}/#{repo.name}"
  end
end

class CreateEvent < Event
  include LinkToRepo
  def type
    "created #{payload.ref_type}"
  end
  def content
    payload.ref
  end
end

class DeleteEvent < Event
  include LinkToRepo
  def type
    "deleted #{payload.ref_type}"
  end
  def content
    payload.ref
  end
end

class PushEvent < Event
  include LinkToRepo
  def type
    "pushed"
  end
  def content
    payload.ref.gsub(%r{\Arefs/heads/}, '')
  end
end

class ReleaseEvent < Event
  include LinkToRepo
  def type
    "released"
  end
  def content
    payload.release.name
  end
end

class GollumEvent < Event
  include LinkToRepo
  def type
    'wiki change'
  end
  def content
    payload.pages.map do |page|
      "#{page.action}: \"#{page.title}\""
    end.join(', ').truncate SCREEN_WIDTH
  end
end

class UserEvents
  def initialize(user, back_to: 1.week.ago)
    @events  = Octokit.user_events user
    @back_to = back_to
  end

  def each
    loop do
      get_more if @events.empty?
      event = @events.shift
      return if event.created_at < @back_to
      yield event
    end
  end

  private

  def get_more
    @events = Octokit.get(Octokit.last_response.rels[:next].href)
    fail 'No more!' if @events.empty?
  end
end

# get a week's worth here

UserEvents.new('mgee', back_to: Time.current.beginning_of_day - 1.week).each do |event|
  begin
    puts event.type.constantize.new(event).to_s
  rescue => _e
    require 'pry'; binding.pry
  end
end
