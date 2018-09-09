# BrightcoveService

Ruby wrapper for creating videos and doing ingestion on brightcove

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brightcove_service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install brightcove_service

## Usage

Gem expects following environment variable to be set correctly:
```
ENV['BRIGHTCOVE_CLIENT_ID']
ENV['BRIGHTCOVE_CLIENT_SECRET']
ENV['BRIGHTCOVE_ACCOUNT_ID']
```

### Creating video on brightcove

```
service = BrightcoveService::Video.new(params)
service.call # return true/false
service.result # get result
service.errors # get errors
```

params:
```
{
  "brightcove_reference_id"=>"FRIENDSS02213",
  "title_en"=>"episode",
  "assets"=>{
    "Go Sample.webp"=>{
      "name"=>"Go", \\ indicates file to be uploaded
      "type"=>"long_form_video",
      "lang"=>"en"
    },
     "0"=>{
     "url"=>"https://homepages.cae.wisc.edu/~ece533/images/airplane.png", \\ indicates url is already present
     "type"=>"thumbnail",
     "lang"=>"en"
     }
  },
  "start_date"=>"2018-08-29 09:19:38",
  "end_date"=>"2018-10-05 09:19:41",
  "restricted"=>"true",
  "exclude_countries"=>"false",
  "countries"=>[
    "IN",
    "ID",
    "SG"
  ]
}
```
Response will be array object.

For each file to be uploaded there will be object in response

object consist of following keys:
```
1. video_id: brightcove video id
2. presigned_url: url on which file should be uploaded
3. request_url: ingestion video url
4. filename: filename
```

### Ingesting video

```
service = BrightcoveService::Ingest.new(params)
service.call # return true/false
service.result # get result
service.errors # get errors
```

params:
```
  "text_tracks"=>{
    "0"=>{
      "url"=>"https://ingestion-upload-production.s3.amazonaws.com/578454510 1001/5832591619001/757ca3c3-a99f-487c-85bf-1badec004cd3/Tomb.Raider.2018.BluRay.720p.x264.DTS-HDC.srt.vtt",
      "lang"=>"en"
    }
  },
  "master_url"=>"https://ingestion-upload-production.s3.amazonaws.com/5784545101001/58325916 19001/9c96277a-69cb-446c-b3ee-6f728662ca92/Go%2520Sample.webp",
  "poster_url"=>"https://ingestion-upload -production.s3.amazonaws.com/5784545101001/5832591619001/350a7d28-9eaf-4ff3-907d-7673ab3e8a24/Sea_LionFish_ poster.png",
  "thumbnail_url"=>"https://homepages.cae.wisc.edu/~ece533/images/airplane.png",
  "video_id"=>"20398234619001"
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anilmaurya/brightcove_service. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BrightcoveService project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/anilmaurya/brightcove_service/blob/master/CODE_OF_CONDUCT.md).
