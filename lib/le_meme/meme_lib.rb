module LeMeme
  # Utility for easily generating memes based off templates
  class MemeLib
    attr_reader :memes
    # Creates a meme library
    #
    # @param [String] *dirs Directory glob patterns to meme templates
    # @return [MemeLib]
    def initialize(*dirs)
      @memes = {}
      dirs.each(&method(:load_directory!))
    end

    # Creates a meme library, preloaded with the included templates
    #
    # @return [MemeLib]
    def self.new_with_default_memes
      path = File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'memes', '*')
      new(path)
    end

    # Loads a directory into the MemeLib, for template consumption
    # Clobbers any existing templates
    #
    # @param [String] dir Directory glob pattern to meme templates
    # @return [Hash] Hash of all templates and their filepaths
    def load_directory!(dir)
      paths = Dir.glob(dir).grep LeMeme::IMAGE_EXTENSIONS
      @memes.merge!(paths.reduce({}) do |images, path|
        path = File.expand_path(path)
        name = path.split.last.sub(LeMeme::IMAGE_EXTENSIONS, '').to_s
        images.merge(name => path)
      end)
    end

    # Create a meme from a template
    #
    # @param [String] template: nil The template to use. Omit for random template
    # @param [String] top: nil
    # @param [String] bottom: nil
    # @param [String] watermark: nil
    # @return [LeMeme::Meme]
    def meme(template: nil, top: nil, bottom: nil, watermark: nil)
      path = template.nil? ? @memes.values.sample : @memes[template]

      Meme.new(path, top: top, bottom: bottom, watermark: watermark)
    end
  end
end
