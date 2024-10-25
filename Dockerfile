# Use Ubuntu 23.10 as the base image
FROM ubuntu:23.10

# Install necessary packages
RUN apt-get update && apt-get install -y \
    squid \
    openssl \
    apache2-utils \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /etc/squid/ssl_cert /etc/squid

# Generate a self-signed SSL certificate
RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=proxy.example.com" \
    -keyout /etc/squid/ssl_cert/mykey.pem \
    -out /etc/squid/ssl_cert/mycert.pem

# Set permissions for the SSL certificate
RUN chown proxy:proxy /etc/squid/ssl_cert/mykey.pem /etc/squid/ssl_cert/mycert.pem
RUN chmod 600 /etc/squid/ssl_cert/mykey.pem /etc/squid/ssl_cert/mycert.pem

# Create an authentication password file
RUN htpasswd -cb /etc/squid/passwords user1 password1
RUN chown proxy:proxy /etc/squid/passwords
RUN chmod 640 /etc/squid/passwords

# Copy the Squid configuration file
COPY squid.conf /etc/squid/squid.conf

# Expose the HTTPS port
EXPOSE 3128

# Start Squid when the container launches
CMD ["squid", "-N", "-f", "/etc/squid/squid.conf"]
