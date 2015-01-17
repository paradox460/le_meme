require 'spec_helper'

describe LeMeme do
  let(:meme) { LeMeme.new }

  describe '#generate' do
    let(:image) { File.join(File.dirname(File.expand_path(__FILE__)), '../memes/maymay.jpg') }
    context 'without an image path' do
      it 'should raise ArgumentError with "missing keyword: path"' do
        expect { meme.generate }.to raise_error(ArgumentError, 'missing keyword: path')
      end
    end
    context 'with an image path' do
      x = ['text', nil] * 3
      x.permutation(3).to_a.uniq.each do |top, bottom, watermark|
        it "should generate a meme with top: '#{top}', bottom: '#{bottom}', and watermark: '#{watermark}'" do
          expect_any_instance_of(Magick::ImageList).to receive(:write).and_return("/tmp/meme-#{Time.now.to_i}.jpg")
          expect(meme.generate(path: image, top: top, bottom: bottom, watermark: watermark)).to match(%r{/tmp/meme-\d+.jpg})
        end
      end
    end
    context 'with an outpath' do
      it 'should generate a meme at the specified outpath' do
        expect_any_instance_of(Magick::ImageList).to receive(:write).and_return('test.jpg')
        expect(meme.generate(path: image, top: 'top', bottom: 'bottom', outpath: 'test.jpg')).to eq('test.jpg')
      end
    end
  end

  describe '#meme' do
    it 'should be an alias of #generate' do
      expect(meme.method(:meme)).to eq(meme.method(:generate))
    end
  end

  describe '#fast_meme' do
    let(:template) { 'maymay' }
    it 'should pass its params to generate_meme' do
      expect(meme).to receive(:generate) do |args|
        expect(args[:path]).to eq(Pathname.new('/Users/jeffsandberg/Developer/le_meme/memes/maymay.jpg'))
        expect(args[:top]).to eq('top text')
        expect(args[:bottom]).to eq('bottom text')
        expect(args[:watermark]).to eq('watermark')
        expect(args[:outpath]).to eq('outpath')
      end
      meme.fast_meme(name: template, top: 'top text', bottom: 'bottom text', watermark: 'watermark', outpath: 'outpath')
    end

    context 'without a specified template' do
      it 'should generate a meme' do
        expect_any_instance_of(Magick::ImageList).to receive(:write).and_return("/tmp/meme-#{Time.now.to_i}.jpg")
        expect(meme.fast_meme).to match(%r{/tmp/meme-\d+.jpg})
      end
    end
  end

  describe '#m' do
    it 'should be an alias of #fast_meme' do
      expect(meme.method(:m)).to eq(meme.method(:fast_meme))
    end
  end
end
