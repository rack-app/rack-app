require 'spec_helper'
describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  describe '#logger' do
    [:info, :warn, :error, :fatal].each do |log_level|
      context "when #{log_level} log level used" do
        rack_app do

          apply_extension :logger

          get do
            logger.__send__(log_level, 'hello')

            return 'OK'
          end

        end

        it "should create log with the logger instance :#{log_level} method" do
          log_level_short_hand = log_level.to_s.upcase[0..0]
          date_identifier = '\d+\-\d+\-\d+T\d+:\d+:\d+\.\d+ #\d+'
          rgx = /#{log_level_short_hand}, \[#{date_identifier}\] +#{log_level.to_s.upcase} +\-\- [\d\w]+: hello\n/
          expect(STDOUT).to receive(:write).with(rgx)
          get('/')
        end

      end
    end

    context "when :unknown log level used" do
      rack_app do

        apply_extension :logger

        get do
          logger.unknown 'hello'

          return 'OK'
        end

      end

      it "should create log with the logger instance :unknown method" do
        date_identifier = '\d+\-\d+\-\d+T\d+:\d+:\d+\.\d+ #\d+'
        rgx = /A, \[#{date_identifier}\] +ANY +\-\- [\d\w]+: hello\n/
        expect(STDOUT).to receive(:write).with(rgx)
        get('/')
      end

    end

    context "when request_id passed in headers" do

      rack_app do

        apply_extension :logger

        get do
          logger.info 'some msg'

          return 'OK'
        end

      end

      it "should use as transactional id" do
        request_id = 'helloworld123'
        expect(STDOUT).to receive(:write).with(/#{request_id}/)
        get('/', :headers => {'X-Request-Id' => request_id})
      end

    end

    context "when hash passed to logger" do

      rack_app do

        apply_extension :logger

        get do
          logger.info :hello => 'world'

          return 'OK'
        end

      end

      it "should use as transactional id" do
        rack_app
        request_id = '123'
        time_now = Time.now
        allow(Time).to receive(:now).and_return(time_now)

        if defined?(::JSON)
          json = JSON.dump('hello' => 'world')
          expect(STDOUT).to receive(:write).with(/#{Regexp.escape(json)}/)
        else
          inspected = {:hello => 'world'}.inspect
          expect(STDOUT).to receive(:write).with(/#{Regexp.escape(inspected)}/)
        end

        get('/', :headers => {'X-Request-Id' => request_id})
      end

    end

  end
end
