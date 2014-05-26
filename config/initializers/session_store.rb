# Be sure to restart your server when you modify this file.

#Arci::Application.config.session_store :cookie_store, key: '_Arci_session', :expire_after => 10.minutes

Arci::Application.config.session_store :active_record_store#, { :expire_after => 10.minutes }
ActiveRecord::SessionStore::Session.attr_accessible :data, :session_id
