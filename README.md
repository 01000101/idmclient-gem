# FreeIPA & Red Hat Identity Management (IdM) Client

## Installation

### General

This Gem is published and can be found at https://rubygems.org/gems/idmclient .

To install locally, simply run `gem install idmclient`. 

### Cloudforms / ManageIQ

In `/var/www/miq/vmdb` (you can get there by simply executing `vmdb`), edit the `Gemfile` to include a new line:

`gem 'idmclient', '~> 0.1.1'`

Then update the Gems by executing `bundle update`. That's it. :)

## Examples

### Authentication

```ruby
require 'idmclient'

# Init a connection
idm = IDMClient.new('https://ipa.acme.co/ipa')
# Authentication w/ username + password
idm.authenticate('YOUR_USERNAME', 'YOUR_PASSWORD')
```

### Show user information
```ruby
# Show an existing user
user = idm.call('user_show', ['my-username'])
```

### Add a new user
```ruby
# Create a new user
user = idm.call('user_add', ['my-new-user'], {
  :givenname => 'Aaron',
  :sn => 'Aardvark',
  :cn => 'Aaron Aardvark',
  :initials => 'AA',
  :homedirectory => '/home/my-new-user',
  :krbprincipalname => 'my-new-user@ACME.CO',
  :random => true,
  :noprivate => false
})
```

### Add user to a group
```ruby
# Add an existing user to an existing group
idm.call('group_add_member', ['cool-group'], {:user => 'my-new-user'})
```

### Delete a user
```ruby
# Delete an existing user
idm.call('user_del', ['my-new-user'])
```
