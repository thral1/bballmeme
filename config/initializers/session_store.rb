# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bballmeme_new_session',
  :secret      => 'aee37dbc1df6425e335b42af567f78c516363bc8d91990093ce3772960bde997142f816ffdb6337ce2a55dd9acd91042611f8ae0d45c40deccbe0752b4772123'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
