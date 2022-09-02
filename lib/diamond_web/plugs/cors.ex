defmodule DiamondWeb.Plugs.CORS do
  use Corsica.Router,
    origins: [],
    allow_headers: [
      "DNT",
      "Keep-Alive",
      "User-Agent",
      "X-Requested-With",
      "If-Modified-Since",
      "Cache-Control",
      "Content-Type"
    ],
    allow_methods: ["HEAD", "GET", "OPTIONS"],
    max_age: 86400

  # resource("/fonts/*")
end
