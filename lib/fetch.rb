require 'nokogiri'
require 'sanitize'
require 'open-uri'
require 'digest/md5'

class Fetch

    def self.run
        content = self.get_content

        toc = self.parse_toc content
        self.remove_elements content
        self.transform_code content
        self.absolute_links content
        self.cleanup_paragraphs content
        self.cleanup_headings content

        ['id', 'lang', 'dir'].each { |e| content[0].remove_attribute(e) }

        return content
    end

    private

    # Get the goods, sorry for the global
    def self.get_content
        $doc = Nokogiri::HTML(self.download('https://wiki.gnome.org/Projects/Vala/Tutorial'))
        $doc.css('#content')
    end

    def self.parse_toc content
        content.css('.table-of-contents > ol > li > ol')
    end

    def self.cleanup_headings content
        content.css('h1, h2, h3, h4, h5, h6').each do |h|
            h.set_attribute('id', h.attr('id').gsub('?', ''))
        end
    end

    def self.absolute_links content
        content.css('a').each do |a|
            if a.attr('href').starts_with '/'
                a.set_attribute('href', 'https://wiki.gnome.org' + a.attr('href'))
            end
        end
    end

    def self.cleanup_paragraphs content
        content.css('p').each do |p|
            p.remove_attribute('class')
            p.remove if p.content.strip.empty?
        end
    end

    # Removes individual or groups of elements
    def self.remove_elements content
        ['span.anchor','.table-of-contents', 'div.comment'].each { |el| content.css(el).remove }
    end

    def self.transform_code content
        content.css('.highlight').each do |el|
            pre = Nokogiri::XML::Node.new 'pre', $doc
            # cleaning non breaking spaces
            pre.content = el.text.gsub("\u00A0", ' ')
            el.replace(pre)
        end

        content.css('tt.backtick').each do |el|
            code = Nokogiri::XML::Node.new 'code', $doc
            code.content = el.text.gsub("\u00A0", ' ')
            el.replace(code)
        end
    end

    # Simple caching
    def self.download url
        Dir.mkdir('cache') unless File.exists?('cache')
        filename = Digest::MD5.hexdigest(url)
        if File.exists?('cache/' + filename)
            File.read('cache/' + filename)
        else
            data = open(url).read
            File.write('cache/' + filename, data)
            return data
        end
    end
end