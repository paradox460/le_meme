module LeMeme
  # A single meme object
  class Meme
    attr_accessor(*%i(path top bottom watermark))
    # @param [String, Pathanem] path Path to an image for the meme background
    # @param [String] top: nil The text on the top of the meme
    # @param [String] bottom: nil The text on the bottom of the meme
    # @param [String] watermark: nil Watermark text
    # @return [Meme] A new meme object
    def initialize(path, top: nil, bottom: nil, watermark: nil)
      @path = File.expand_path(path)
      @top = top.to_s.upcase
      @bottom = bottom.to_s.upcase
      @watermark = watermark
      @canvas = Magick::ImageList.new(@path)
    end

    # Outputs the meme to the file system
    #
    # @param [String] path = nil Where to save the meme
    # @return [File] File object representing the meme
    def to_file(path = nil)
      path = File.expand_path(path.nil? ? "#{ENV['TMPDIR']}meme-#{Time.now.to_i}.jpg" : path)
      generate!

      file = File.new(path, 'w+')
      @canvas.write(path)

      file
    end

    # Get a binary string representing the meme
    #
    # @return [String]
    def to_blob
      generate!

      @canvas.to_blob
    end

    private

    def generate!
      return if @generated
      @generated = true
      caption(@top, Magick::NorthGravity) unless @top.empty?
      caption(@bottom, Magick::SouthGravity) unless @bottom.empty?
      watermark unless watermark.nil?
    end

    # rubocop:disable Metrics/MethodLength
    def caption(text, gravity)
      text = word_wrap(text)
      draw, pointsize = calculate_pointsize(text)

      draw.annotate(@canvas, @canvas.columns, @canvas.rows - 10, 0, 0, text) do
        self.interline_spacing = -(pointsize / 5)
        stroke_antialias(true)
        self.stroke = 'black'
        self.fill = 'white'
        self.gravity = gravity
        self.stroke_width = pointsize / 30.0
        self.pointsize = pointsize
      end
    end
    # rubocop:enable Metrics/MethodLength

    def watermark
      draw = Magick::Draw.new
      draw.annotate(@canvas, 0, 0, 0, 0, " #{@watermark}") do
        self.fill = 'white'
        text_antialias(false)
        self.font_weight = 100
        self.gravity = Magick::SouthEastGravity
        self.pointsize = 10
        self.undercolor = 'hsla(0,0,0,.5)'
      end
    end

    # rubocop:disable Metrics/AbcSize
    def calculate_pointsize(text, size_range: 28...128)
      draw = Magick::Draw.new
      draw.font = File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'fonts', 'Impact.ttf')
      draw.font_weight = Magick::BoldWeight

      size = size_range.detect(-> { size_range.last }) do |pointsize|
        draw.pointsize = pointsize + 1
        current_stroke = pointsize / 30.0

        metrics = draw.get_multiline_type_metrics(text)

        metrics.width + current_stroke > @canvas.columns - 20 || metrics.height + current_stroke > (@canvas.rows / 2) - 20
      end
      [draw, size]
    end
    # rubocop:enable Metrics/AbcSize

    def word_wrap(text, col: 24)
      text.strip.gsub(/\n\r/, '\s')
      text = WordWrapper::MinimumRaggedness.new(col, text).wrap
      text = text.split("\n").map do |line|
        line.length > col ? line.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n").strip : line
      end * "\n"
      text.strip
    end
  end
end
