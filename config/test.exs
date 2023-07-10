import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :maccle_web, MaccleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6/lGs9meu0ttQtRk7QjrTnf33pj7hE5RA+WStoz14uhq+Q9ALfeu8E43Os4F5/fN",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails.
config :maccle, Maccle.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
