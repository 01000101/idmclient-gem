# FreeIPA & Red Hat Identity Management (IdM) Client

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
