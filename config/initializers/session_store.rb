# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_expenses_session',
  :secret      => '1dbccf000222d808c064fb3de0604f6540bafa0e34a253fd691f00d4c70e05d6584298cf0e1f006b05ecd82d4308f5d8012b383e2d2ded32273e85b73e7fc053'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
