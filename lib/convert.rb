require 'eeepub'

epub = EeePub.make do
  title       'Vala Tutorial'
  creator     'Maciej Piechotka'
  publisher   'Samuel Vasko'
  date        '2014-01-25'
  identifier  'http://example.com/book/foo', :scheme => 'URL'
  uid         'http://example.com/book/foo'


  files ['/path/to/foo.html', '/path/to/bar.html'] # or files [{'/path/to/foo.html' => 'dest/dir'}, {'/path/to/bar.html' => 'dest/dir'}]
  nav [
    {:label => '1. foo', :content => 'foo.html', :nav => [
      {:label => '1.1 foo-1', :content => 'foo.html#foo-1'}
    ]},
    {:label => '1. bar', :content => 'bar.html'}
  ]
end
epub.save('sample.epub')