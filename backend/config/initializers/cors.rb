Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Ensure schemes are present; browsers require absolute (http/https) origins for CORS
    origins(
      "http://localhost:3001",
      "http://127.0.0.1:3001"
    )
    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
