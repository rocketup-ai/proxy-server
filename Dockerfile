# Use Debian Bookworm Slim as the base image
FROM debian:bookworm-slim

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    squid-openssl \
    openssl \
    apache2-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /etc/squid/ssl_cert /etc/squid

# Generate a self-signed SSL certificate
RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=proxy.example.com" \
    -keyout /etc/squid/ssl_cert/mykey.pem \
    -out /etc/squid/ssl_cert/mycert.pem

# Set permissions for the SSL certificate
RUN chown proxy:proxy /etc/squid/ssl_cert/mykey.pem /etc/squid/ssl_cert/mycert.pem \
    && chmod 600 /etc/squid/ssl_cert/mykey.pem /etc/squid/ssl_cert/mycert.pem

# Create an authentication password file
RUN htpasswd -cb /etc/squid/passwords user1 password1 \
    && chown proxy:proxy /etc/squid/passwords \
    && chmod 640 /etc/squid/passwords

# Copy the Squid configuration file
COPY squid.conf /etc/squid/squid.conf

# Expose the HTTPS port
EXPOSE 3128

# Start Squid when the container launches
CMD ["squid", "-N", "-f", "/etc/squid/squid.conf"]
