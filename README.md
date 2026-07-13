# Katalyst::Thermite

Katalyst Thermite provides tools for adding and updating libraries and frameworks following Katalyst best practices.

## Installation

Add the gem to the `development` group in your Gemfile:

```ruby
group :development do
  gem "katalyst-thermite"
end
```

## Usage

Run installers to add common frameworks and libraries to your Rails app, for example:

```shell
bin/rails thermite:install:koi
```

Available installers:

```shell
bin/rails thermite:install:active_storage
bin/rails thermite:install:docker
bin/rails thermite:install:solid_cable
bin/rails thermite:install:solid_queue
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/thermite.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
