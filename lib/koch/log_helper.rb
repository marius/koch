# frozen_string_literal: true

require "logger"

module Koch
  # LogHelper provides simple logging for the whole program
  module LogHelper
    @@logger = Logger.new($stdout)
    @@logger.formatter = proc do |_severity, datetime, _progname, msg|
      _ts = datetime.strftime("%F %T")
      # format("%s%s %s\n", severity[0], ts, msg)
      "#{msg}\n"
    end

    def logger
      @@logger
    end

    def debug(*args)
      @@logger.debug(*args)
    end

    def info(*args)
      @@logger.info(*args)
    end

    def warn(*args)
      @@logger.warn(*args)
    end

    def error(*args)
      @@logger.error(*args)
    end

    def fatal(*args)
      @@logger.fatal(*args)
      exit 1
    end
  end
end
