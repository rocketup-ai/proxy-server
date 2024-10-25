# Dockerfile
FROM sameersbn/squid:latest

# Install openssl to generate SSL certificates
RUN apt-get update && apt-get install -y openssl

# Create directory for Squid configuration and SSL certificates
RUN mkdir -p /etc/squid/ssl_cert

# Generate a self-signed SSL certificate
RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
  -keyout /etc/squid/ssl_cert/squid.key \
  -out /etc/squid/ssl_cert/squid.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"

# Combine key and cert into .pem file
RUN cat /etc/squid/ssl_cert/squid.crt /etc/squid/ssl_cert/squid.key > /etc/squid/ssl_cert/squid.pem

# Copy Squid configuration file
COPY squid.conf /etc/squid/squid.conf
