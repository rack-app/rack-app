require 'spec_helper'

describe Rack::App::File::Server do

  let(:app_class) { Class.new(described_class) }
  let(:request_env) do
    {
        'REQUEST_PATH' => '/index.html',
        'REQUEST_METHOD' => 'GET',
    }
  end

  describe '.source_folder' do

    it do
      relative_folder_path = '/spec/rack/app/file/server_spec'

      app_class.source_folder(relative_folder_path)

      response = Rack::Response.new(app_class.call(request_env)[2].body)

      expect(response.body.first).to eq "<h1>Hello World!</h1>"

      expect(response.status).to eq Rack::Response.new.status
    end

  end

  describe '.use_file_parser' do
    let(:parser_class) { double('parser class') }
    let(:extensions) { %w(.hello .world) }
    subject { app_class.use_file_parser(parser_class, *extensions) }

    it 'should allow to fetch the stored parser classes' do
      is_expected.to be nil

      expect(app_class.find_file_parser_class_for('.hello')).to be parser_class
      expect(app_class.find_file_parser_class_for('.world')).to be parser_class
    end

  end

end