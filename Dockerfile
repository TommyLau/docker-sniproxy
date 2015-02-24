FROM debian:jessie

ENV SNIPROXY_VERSION 0.3.6

RUN buildDeps=" \
		autotools-dev \
		build-essential \
		cdbs \
		debhelper \
		devscripts \
		dh-autoreconf \
		dpkg-dev \
		gettext \
		libev-dev \
		libpcre3-dev \
		libudns-dev \
		pkg-config \
		ca-certificates \
		curl \
	"; \
	set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -SL "https://github.com/dlundquist/sniproxy/archive/$SNIPROXY_VERSION.tar.gz" -o sniproxy.tar.gz \
	&& mkdir -p /usr/src/sniproxy \
	&& tar -xf sniproxy.tar.gz -C /usr/src/sniproxy --strip-components=1 \
	&& rm sniproxy.tar.gz \
	&& cd /usr/src/sniproxy \
	&& sed -i 's/0.3.5/0.3.6/' setver.sh \
	&& ./autogen.sh \
	&& dpkg-buildpackage \
	&& cd .. \
	&& dpkg -i sniproxy_"$SNIPROXY_VERSION"_amd64.deb \
	&& rm -fr sniproxy* \
	&& mkdir /etc/sniproxy \
	&& mv /etc/sniproxy.conf /etc/sniproxy/ \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& apt-get autoremove -y

WORKDIR /etc/sniproxy

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/sniproxy","-c","/etc/sniproxy/sniproxy.conf","-f"]
