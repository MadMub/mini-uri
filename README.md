# MiniUri

Generate short(ish), practically unguessable URI for app models, implemented in Plain Old Ruby. MiniUri uses reflection to create uniquely identifiable URI, so `Foo.new.to_muri` and `Bar.new.to_muri` will be different. Should your app use MiniUri to issue permalinks, the links are no longer valid if the secret changes or, as a result of the reflection if the namespace of your class changes (change module, change class name, etc).

NOTE: MiniUri is meant for a specific use case. It was designed for issuing links to "protected" or "unlisted" resources. Despite a cryptographic review, and the potential for use outside this use case, at this time I recommend it be used strictly for sharing unlisted resources (things that are public, but that you'd rather not have the masses and web crawlers have access to, like a sign-in portal tailored to a user or client). A future goal of this project is to allow for pre-authorized actions, however I will wait to see how the gem fares in the wild first.

Please load your secret to `ENV['MINI_URI_SECRET']`, MiniUri assumes no responsibility for your secret. Please make sure it is securely stored, and generated by a good random number generator. A good secret should be 256 bits in length.

NOTE: many secrets are encoded and stored as hex or base64, it is advised to remove the encoding or else risk diluting the entropy of your secret, for hex you can do the following (ruby 2):

```ruby
secret = '000E0000000000'
secret.length
# => 14
ENV["MINI_URI_SECRET"] = [secret].pack('H*')
ENV["MINI_URI_SECRET"].length
# => 7
```
For Base64 use the appropriate method in the Base64 standard library

## Installation

```
gem install mini_uri
```

## Usage

Include MiniUri in any of your app's models.
```ruby
require 'mini_uri'

class User
  include MiniUri

  attr_accessor :id
end
```
MiniUri assumes the model class has an integer attribute `:id` since this is the common practice, however you can generate on any integer value you want.
```ruby
ENV['MINI_URI_SECRET'] = 'this is a bad secret'

user = User.new
user.id = 12345
user.to_muri
# => "3D7-6xtqryABGqkHNGSieho1Do"

User.new.to_muri(12345)
# => "3D7-6xtqryABGqkHNGSieho1Do"
```
now say you have an endpoint `/user/:mini_uri`, in the corresponding controller you could retrieve the actual id and record
```ruby
def show
  id = User.muri_to_id(params[:mini_uri])
  if id == nil
    render_404
  else
    @user = User.find(id)
  end
end
```

## Special Thanks
* [Geoff Longman](https://github.com/glongman)
* [Carlisle Adams](http://www.site.uottawa.ca/~cadams/)
* [Everyone at Fullscript](http://fullscript.com/)
