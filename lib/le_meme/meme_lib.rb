module LeMeme
  # Utility for easily generating memes based off templates
  class MemeLib
    attr_reader :memes
    def initialize(*dirs)
      @memes = {}
      dirs.each(&method(:load_directory!))
    end

    def self.new_with_default_memes
      path = File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'memes', '*')
      new(path)
    end

    def load_directory!(dir)
      paths = Dir.glob(dir).grep LeMeme::IMAGE_EXTENSIONS
      @memes.merge!(paths.reduce({}) do |images, path|
        path = File.expand_path(path)
        name = path.split.last.sub(LeMeme::IMAGE_EXTENSIONS, '').to_s
        images.merge(name => path)
      end)
    end

    def meme(template: nil, top: nil, bottom: nil, watermark: nil)
      path = template.nil? ? @memes.values.sample : @memes[template]

      Meme.new(path, top: top, bottom: bottom, watermark: watermark)
    end
  end
end
