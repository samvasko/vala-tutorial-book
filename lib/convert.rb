require 'eeepub'
require 'nokogiri'
require 'pygments'

class Convert
    def self.run toc
        # Join the forces!
        doc = (['header', 'cache/out', 'footer'].map {|f| File.read(f + '.html')}).join
        toc = self.parse_toc toc
        # doc = self.highlight doc

        File.write('cache/joined.html', doc)

        epub = EeePub.make do
            title       'Vala Tutorial'
            creator     'Gnome'
            publisher   'Samuel Vasko'
            date        '2014-01-25'
            identifier  'https://github.com/bliker/vala-tutorial-book', :scheme => 'URL'
            uid         'https://github.com/bliker/vala-tutorial-book'

            files ['cache/joined.html', 'style.css']
            nav toc
        end
        epub.save('Vala Tutorial.epub')
    end

    # Not jet implemented
    def self.highlight doc
        doc = Nokogiri::HTML(doc)
        doc.css('pre').each do |pre|
            pre.content = Pygments.highlight(pre.text, :lexer => 'vala')
        end

        doc.to_html
    end

    def self.parse_toc doc
        doc = Nokogiri::HTML(doc)
        self.mush_ol(doc.css('body > ol'))
    end

    def self.mush_li li
        data = {
            :label => li.css('> a').text,
            :content => 'joined.html' + li.css('a').attr('href')
        }
        unless li.css('ol').empty?
            data[:nav] = self.mush_ol(li.css('ol'))
            return data
        else
            return data
        end
    end

    def self.mush_ol ol
        out = []
        ol.children.map do |li|
            if li.name == 'li'
                out << self.mush_li(li)
            end
        end

        return out
    end

end