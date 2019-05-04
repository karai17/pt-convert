FROM centos:latest

LABEL maintainer="Landon Manning <lmanning17@gmail.com>"

# Environment
ARG LUAROCKS_VERSION="3.0.4"

# Prepare volumes
VOLUME /var/data
VOLUME /var/src

# Entry
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Make executable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Install from Yum
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum clean all
RUN yum -y install \
      gcc \
      git \
		GraphicsMagick \
		GraphicsMagick-devel \
		ImageMagick \
		ImageMagick-devel \
		luajit \
		luajit-devel \
      make \
      unzip; \
    yum clean all

# Install LuaRocks
RUN cd /tmp  \
 && curl -fSL http://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -o luarocks-${LUAROCKS_VERSION}.tar.gz \
 && tar xzf luarocks-${LUAROCKS_VERSION}.tar.gz \
 && cd luarocks-${LUAROCKS_VERSION} \
 && ./configure \
      --prefix=/usr \
		--with-lua=/usr \
      --with-lua-include=/usr/include/luajit-2.0 \
 && make build \
 && make install \
 && cd /

# Install from LuaRocks
RUN luarocks install luafilesystem
RUN luarocks install magick

# Cleanup /tmp
RUN rm /tmp/* -r

# Cleanup yum
RUN yum -y remove \
      gcc \
      git \
      make \
		perl \
      unzip; \
    yum clean all

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
