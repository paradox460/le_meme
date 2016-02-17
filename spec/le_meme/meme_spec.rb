require 'spec_helper'

describe LeMeme::Meme do
  subject { LeMeme::Meme.new('memes/maymay.jpg') }
  describe :new do
    context 'without text' do
      it { is_expected.to be_a LeMeme::Meme }
      it { expect(subject.path).to match(%r{memes/maymay.jpg$}) }
    end

    context 'with text' do
      subject do
        LeMeme::Meme.new('memes/maymay.jpg', top: 'top text', bottom: 'bottom text')
      end

      it { expect(subject.top).to eql('TOP TEXT') }
      it { expect(subject.bottom).to eql('BOTTOM TEXT') }
    end
  end

  describe :to_file do
    it { expect(subject.to_file).to be_a(File) }
    it { expect(subject.to_file.path).to match(/#{ENV['TMPDIR']}meme-\d+.jpg/) }
  end

  describe :to_blob do
    it { expect(subject.to_blob).to be_a(String) }
    it { expect(subject.to_blob.size).to eql(43_685) }
  end
end
