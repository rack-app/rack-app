require 'spec_helper'
require 'rack/app/test'

out_file = Rack::App::Utils.pwd('spec', 'fixtures', 'out')
in_file = Rack::App::Utils.pwd('spec', 'fixtures', 'in')

InstanceMethodsSpec = Class.new
describe Rack::App::InstanceMethods do

  include Rack::App::Test

  rack_app do

    get '/serve_file' do
      serve_file Rack::App::Utils.pwd('spec', 'fixtures', 'raw.txt')
    end

    get '/redirect_to' do
      redirect_to '/hello'
    end

    get '/payload_to_file' do
      payload_to_file(out_file)
    end

  end

  describe '#serve_file' do

    it 'should serve file content with Rack::File' do
      response = get(:url => '/serve_file')

      expect(response.body).to be_a ::Rack::File

      content = ''
      response.body.each { |chunk| content << chunk }

      expect(content).to eq "hello world!\nhow you doing?"

    end

  end

  describe '#stream_payload_to' do

    before do
      [in_file, out_file].each { |fp| File.delete(fp) if File.exist?(fp) }

      example_line_str = "o" * 1024 * 1024
      File.open(in_file, 'w') do |file|
        1024.times do
          line = example_line_str

          file.puts(line)
        end
      end

    end

    it 'should be easy and memory efficient to steam 1Gb payload into a file' do
      get(:url => '/payload_to_file', :payload => File.open(in_file))

      expect(File.size(in_file)).to eq File.size(out_file)
    end

    after do
      [in_file, out_file].each { |fp| File.delete(fp) if File.exist?(fp) }
    end

  end

  describe '#redirect_to' do

    it 'should set status to 301' do
      expect(get(:url => '/redirect_to').status).to eq 301
    end

    it 'should add location header' do
      expect(get(:url => '/redirect_to').headers['Location']).to eq '/hello'
    end

    it 'should add params to location url too to proxy the request' do
      expect(get(:url => '/redirect_to', :params => {'hello' => 'world'}).headers['Location']).to eq '/hello?hello=world'
    end

  end

end