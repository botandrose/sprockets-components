# Sprockets::Components

Make web components easier to develop in Rails using Sprockets.

## Installation

Just add `gem "sprockets-components` to your Gemfile.

## Usage

Use one directory per component, under `app/assets/components`:

```
app/assets/
└── components
    └── my-counter
        ├── my-counter.js
        ├── my-counter.scss
        └── my-counter.slim
```

At the top of the main my-counter.js component file, add the `component` directive:
```js
//= component

customElements.define("my-counter", class extends HTMLElement {
  // ...
})
```

This directive exposes an `HTML` variable for use in the component. It is a string of the compiled template, with the compiled CSS inlined into an interior <style> tag.

Use the component in your views, as you'd expect. Sprockets compiles it all down to a single compiled js file. This file can be included directly, or `//= require`d into other files, or exposed to the importmap, or whatever you want!
```html.erb
<!-- app/views/test/test.html.erb -->
<%= javascript_include_tag "my-counter" %>
<my-counter value="0"></my-counter>
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/botandrose/sprockets-components.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
