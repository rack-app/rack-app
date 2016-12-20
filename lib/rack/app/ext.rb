selector = Regexp.new(Regexp.escape(File.join('rack-app')))
$LOAD_PATH.select { |path| path =~ selector }.each do |lib_folder|
  glob_path = File.join(lib_folder, 'rack', 'app', 'ext', '*.{rb,ru}')
  Dir.glob(glob_path).each do |file_path|
    require(file_path)
  end
end
