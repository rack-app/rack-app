require 'spec_helper'
require 'rack/app/test'
require 'securerandom'
require 'tmpdir'

out_file = File.join(Dir.tmpdir,SecureRandom.hex)
in_file = File.join(Dir.tmpdir,SecureRandom.hex)

Kernel.at_exit do
  [in_file, out_file].each { |fp| File.delete(fp) if File.exist?(fp) }
end

InstanceMethodsSpec = Class.new
describe Rack::App::InstanceMethods do

  include Rack::App::Test

  rack_app do

    get '/serve_file' do
      serve_file Rack::App::Utils.pwd('spec', 'fixtures', 'raw.txt')
    end

    get '/serve_file_break_execution' do
      serve_file Rack::App::Utils.pwd('spec', 'fixtures', 'raw.txt')
      raise 'not raised'
    end

    get '/redirect_to' do
      redirect_to '/hello'
    end

    get '/redirect_to_with_params' do
      redirect_to '/hello', :hello => 'world'
    end

    get '/redirect_to_break_execution' do
      redirect_to '/hello'
      raise 'never happen'
    end

    get '/payload_to_file' do
      payload_to_file(out_file)
    end

  end

  describe '#serve_file' do

    it 'should serve file content with Rack::File' do
      response = get(:url => '/serve_file')

      expect(response.status).to eq 200
      expect(response.body).to eq "hello world!\nhow you doing?"
      expect(response.body).to eq "hello world!\nhow you doing?"

      new_response = get(:url => '/serve_file',
                         :headers => {'IF_MODIFIED_SINCE' => response.headers["Last-Modified"]})

      expect(new_response.status).to eq 304

    end

    it 'should break the flow of the code processing' do
      expect{get(:url => '/serve_file_break_execution')}.to_not raise_error
      response = get(:url => '/serve_file_break_execution')
      expect(response.status).to eq 200
      expect(response.body).to eq "hello world!\nhow you doing?"
    end

  end

  describe '#stream_payload_to' do

    file_size_in_mb = (ENV['STREAM_FILE_SIZE'] || 128).to_i

    before do
      [in_file, out_file].each { |fp| File.delete(fp) if File.exist?(fp) }

      line_size = 1024 * 1024
      example_line_str = "o" * line_size

      File.open(in_file, 'w') do |file|
        file_size_in_mb.times do
          line = example_line_str

          file.puts(line)
        end
      end

    end

    it "should be easy and memory efficient to steam #{file_size_in_mb} MByte payload into a file" do
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

    it 'should break the control flow of the code block' do
      expect{ get(:url => '/redirect_to_break_execution') }.to_not raise_error
    end

    it 'should add location header' do
      expect(get(:url => '/redirect_to').headers['Location']).to eq '/hello'
    end

    it 'should add params to location url too to proxy the request' do
      expect(get(:url => '/redirect_to', :params => {'hello' => 'world'}).headers['Location']).to eq '/hello?hello=world'
    end

    it 'should parse the optionally given hash to the repsonse' do
      expect(get(:url => '/redirect_to_with_params').headers['Location']).to eq '/hello?hello=world'
    end

    it 'should prefer the passed hash over the origin QUERY_STRING' do
      expect(get(:url => '/redirect_to_with_params', :params => {'nope' => 'not passed'}).headers['Location']).to eq '/hello?hello=world'
    end

  end

end
