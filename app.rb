require 'pp'

$LOAD_PATH << './lib'

require 'fetch'
require 'convert'

content, toc = Fetch.run
File.write('cache/out.html', content)
Convert.run toc