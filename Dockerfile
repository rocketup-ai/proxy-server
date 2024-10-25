# Use a lightweight base image
FROM debian:bullseye-slim

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libssl-dev \
    libexpat1-dev \
    libpcre2-dev \
    libcap2-dev \
    libkrb5-dev \
    libdb-dev \
    libnetfilter-conntrack-dev \
    perl \
    pkg-config \
    ca-certificates \
    openssl \
    apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# Set Squid version
ENV SQUID_VERSION 6.1

# Download and build Squid
RUN wget http://www.squid-cache.org/Versions/v6/squid-$SQUID_VERSION.tar.gz && \
    tar xzf squid-$SQUID_VERSION.tar.gz && \
    cd squid-$SQUID_VERSION && \
    ./configure --prefix=/usr/local/squid \
                --enable-ssl \
                --enable-ssl-crtd \
                --disable-cache-digests \
                --disable-icmp \
                --disable-wccp \
                --disable-wccpv2 \
                --disable-snmp \
                --enable-auth \
                --with-openssl \
                --enable-basic-auth-helpers=NCSA \
                --disable-cache \
                --enable-forward-log \
                --enable-follow-x-forwarded-for && \
    make && make install && \
    cd .. && rm -rf squid-$SQUID_VERSION*

# Create necessary directories
RUN mkdir -p /etc/squid/ssl_cert /etc/squid

# Generate a self-signed SSL certificate
RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=proxy.example.com" \
    -keyout /etc/squid/ssl_cert/mykey.pem \
    -out /etc/squid/ssl_cert/mycert.pem

# Create an authentication password file
RUN htpasswd -cb /etc/squid/passwords user1 password1

# Copy the Squid configuration file
COPY squid.conf /usr/local/squid/etc/squid.conf

# Initialize Squid cache directories
RUN /usr/local/squid/sbin/squid -Nz

# Expose the HTTPS port
EXPOSE 3128

# Start Squid when the container launches
CMD ["/usr/local/squid/sbin/squid", "-NYCd", "1"]
