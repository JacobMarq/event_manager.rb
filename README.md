# event_manager.rb
A ruby event manager that takes a list of attendees, organizes their information, finds their government legislators using a zip code with the Google Civic Information API, and creates a Thank-You-Letter file.

    Things I Learned:
      -manipulate file input and output
      -read content from a CSV (Comma Separated Value) file
      -transform it into a standardized format
      -utilize the data to contact a remote service
      -populate a template with user data
      -manipulate strings
      -access Google’s Civic Information API through the Google API Client Gem
      -use ERB (Embedded Ruby) for templating
