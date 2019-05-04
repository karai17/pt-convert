FROM centos:latest

LABEL maintainer="Landon Manning <lmanning17@gmail.com>"

# Environment
ARG LUAROCKS_VERSION="3.0.4"
ARG IMAGEMAGICK_VERSION="7.0.8-44"

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
	luajit \
	luajit-devel \
	make \
	unzip; \
yum clean all

# Install ImageMagick
RUN cd /tmp \
&& curl -fSL https://www.imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-${IMAGEMAGICK_VERSION}.x86_64.rpm -o ImageMagick-${IMAGEMAGICK_VERSION}.x86_64.rpm \
&& curl -fSL https://www.imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-libs-${IMAGEMAGICK_VERSION}.x86_64.rpm -o ImageMagick-libs-${IMAGEMAGICK_VERSION}.x86_64.rpm \
&& curl -fSL https://www.imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-devel-${IMAGEMAGICK_VERSION}.x86_64.rpm -o ImageMagick-devel-${IMAGEMAGICK_VERSION}.x86_64.rpm \
&& yum -y localinstall ./ImageMagick-${IMAGEMAGICK_VERSION}.x86_64.rpm ./ImageMagick-libs-${IMAGEMAGICK_VERSION}.x86_64.rpm ./ImageMagick-devel-${IMAGEMAGICK_VERSION}.x86_64.rpm

# Install LuaRocks
RUN cd /tmp \
&& curl -fSL http://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -o luarocks-${LUAROCKS_VERSION}.tar.gz \
&& tar xzf luarocks-${LUAROCKS_VERSION}.tar.gz \
&& cd luarocks-${LUAROCKS_VERSION} \
&& ./configure \
	--prefix=/usr \
	--with-lua=/usr \
	--with-lua-include=/usr/include/luajit-2.0 \
&& make build \
&& make install

# Install from LuaRocks
RUN luarocks install luafilesystem
RUN luarocks install magick

# Cleanup /tmp
RUN cd / \
&& rm /tmp/* -r

# Cleanup yum
RUN yum -y remove \
	gcc \
	git \
	make \
	perl \
	unzip; \
yum clean all

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
