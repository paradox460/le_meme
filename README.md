# Le Meme

A tool for making dank memes!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'le_meme'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lememe

## Usage

### I WANT A MEME NOW!
Use the command-line tool, `meme`:

```sh
meme 'i want a' 'dank meme'
```
<image goes here>

### I want to see the command line options
You can do most meme-ish things from the command-line. It has interactive help at `meme -h`.  
Should be straightforward enough for even the dankest memer.

### I want to make memes in my ruby application
Easy enough!

```ruby
require 'le_meme'

meme = LeMeme.new

meme.m(top: 'dank memes!', bottom: 'bottom text')
```

See the [docs]() for all the shrektastic details

## Contributing

1. Fork it ( https://github.com/paradox460/lememe/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## WHY?
Because the world needs more dank memes!

Actually, because I wanted to take some time and clean up the core of [memebot](http://github.com/paradox460/memebot), and figured making the essential meme generation a gem was the best way to do it. Now I can spam my coworkers with memes in hipchat as well.

## TODO
- [ ] Test suite
- [ ] Accept non-tmp dir meme generation paths

## License

```
Copyright (c) 2015 Jeff Sandberg

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
