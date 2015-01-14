require 'le_meme/version'
require 'rmagick'
require 'word_wrapper'

# Create some dank memes
#
# @author Jeff Sandberg <paradox460@gmail.com>
class LeMeme
  VALID_IMAGE_EXTENSIONS = /\.(jp[e]?g|png|gif)$/i

  attr_reader :memes

  # Create a new instance of LeMeme, for generating memes.
  #
  # @param [Array] Directories of images you want the gem to know about. Scrapes images in said directory
  # @return [String] description of returned object
  def initialize(*dirs)
    @memes = {}
    load_directory!
    dirs.each do |dir|
      load_directory!(dir)
    end
  end

  # Create a meme with the given text
  #
  # @param path [String] The path to the image file you want to annotate.
  # @param top [String] The text you want to appear on the top of the meme.
  # @param bottom [String] The text you want to appear on the bottom of the meme.
  # @param watermark [String] The watermark text. If nil it is omitted
  # @param outpath [String] Where do you want to put the generated meme. Defaults to /tmp/
  # @return [String] Path to the generated meme
  def generate(path:, top: nil, bottom: nil, watermark: nil, outpath: nil)
    top = (top || '').upcase
    bottom = (bottom || '').upcase

    path = Pathname.new(path).realpath

    canvas = Magick::ImageList.new(path)

    caption_meme(top, Magick::NorthGravity, canvas) unless top.empty?
    caption_meme(bottom, Magick::SouthGravity, canvas) unless bottom.empty?

    # Draw the watermark
    unless watermark.nil?
      watermark_draw = Magick::Draw.new
      watermark_draw.annotate(canvas, 0, 0, 0, 0, " #{watermark}") do
        self.font = 'Helvetica'
        self.fill = 'white'
        self.text_antialias(false)
        self.font_weight = 100
        self.gravity = Magick::SouthEastGravity
        self.pointsize = 10
        self.undercolor = 'hsla(0,0,0,.5)'
      end
    end

    output_path = outpath || "/tmp/meme-#{Time.now.to_i}#{path.extname}"
    canvas.write(output_path)
    output_path
  end
  alias_method :meme, :generate

  # Create a meme, using the pre-loaded templates.
  # If no template is specified, randomly picks one
  #
  # @param name [String] Name of the template to use. See #memes
  # @param top [String] The text you want to appear on the top of the meme.
  # @param bottom [String] The text you want to appear on the bottom of the meme.
  # @param watermark [String] The watermark text. If nil it is omitted
  # @param outpath [String] Where do you want to put the generated meme. Defaults to /tmp/
  # @return [String] Path to the generated meme
  def fast_meme(name: nil, top: nil, bottom: nil, watermark: nil, outpath: nil)
    if name.nil?
      path = @memes[@memes.keys.sample]
    elsif @memes[name].nil?
      fail ArgumentError, "#{name} is not a pre-loaded meme"
    else
      path = @memes[name]
    end
    generate(path: path, top: top, bottom: bottom, watermark: watermark, outpath: outpath)
  end
  alias_method :m, :fast_meme

  private

  # Load all images in a directory as memes.
  # Last loaded directory overrides first, if there are name conflicts.
  #
  # @param directory [String] Directory to scrape.
  def load_directory!(directory = nil)
    directory = directory.nil? ? "#{File.join(File.dirname(File.expand_path(__FILE__)), '../memes')}/*.jpg" : "#{directory}/*"
    paths = Dir.glob(directory).select do |path|
      path =~ VALID_IMAGE_EXTENSIONS
    end
    @memes.merge!(paths.reduce({}) do |images, path|
      path = Pathname.new(path).realpath
      name = path.split.last.sub(VALID_IMAGE_EXTENSIONS, '').to_s
      images.merge(name => path)
    end)
  end

  # Caption a canvas
  #
  # @param text [String] The text to put on as a caption
  # @param gravity [Grav] RMagick Gravity Constant
  # @param canvas [Magick::ImageList] ImageList/Canvas to compose the text onto
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def caption_meme(text, gravity, canvas)
    text.gsub!('\\', '\\\\\\')

    # 28 is the biggest pointsize memes dont look like shit on
    min_pointsize = 28
    max_pointsize = 128
    current_pointsize = min_pointsize
    current_stroke = current_pointsize / 30.0

    max_width = canvas.columns - 20
    max_height = (canvas.rows / 2) - 20

    draw = Magick::Draw.new
    draw.font = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'fonts', 'Impact.ttf')
    draw.font_weight = Magick::BoldWeight
    metrics = nil

    # Non-ragged word-wrap
    text = word_wrap(text)

    # Calculate out the largest pointsize that will fit
    loop do
      draw.pointsize = current_pointsize
      last_metrics = metrics
      metrics = draw.get_multiline_type_metrics(text)

      if metrics.width + current_stroke > max_width ||
         metrics.height + current_stroke > max_height ||
         current_pointsize > max_pointsize
        if current_pointsize > min_pointsize
          current_pointsize -= 1
          current_stroke = current_pointsize / 30.0
          metrics = last_metrics
        end
        break
      else
        current_pointsize += 1
        current_stroke = current_pointsize / 30.0
      end
    end
    # rubocop:disable Style/RedundantSelf
    draw.annotate(canvas, canvas.columns, canvas.rows - 10, 0, 0, text) do
      self.interline_spacing = -(current_pointsize / 5)
      self.stroke_antialias(true)
      self.stroke = 'black'
      self.fill = 'white'
      self.gravity = gravity
      self.stroke_width = current_stroke
      self.pointsize = current_pointsize
    end
    # rubocop:enable Style/RedundantSelf
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # Wrap the text to fit on a meme
  # This basically uses the wordwrapper library, and then does some calculations to split super-long strings
  #
  # @param text [String] The text string to word-wrap.
  # @param col [Fixnum] The number of "columns" to wrap at
  # @return [String] The text, with the
  def word_wrap(text, col: 24)
    text.strip.gsub(/\n\r/, '\s')
    text = WordWrapper::MinimumRaggedness.new(col, text).wrap
    text = text.split("\n").map do |line|
      line.length > col ? line.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n").strip : line
    end * "\n"
    text.strip
  end
end
