require 'pp'

$LOAD_PATH << './lib'

require 'fetch'
require 'convert'

File.write('out.html', Fetch.run())