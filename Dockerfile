FROM jenkins/agent:latest-jdk11

USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto
RUN apt-get update -y \
	&& apt-get -qq install -y supervisor avahi-daemon avahi-utils dbus curl git vim tzdata locales \
	&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
	&& echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
	&& apt-get -qq -y autoclean \
	&& apt-get -qq -y autoremove \
	&& apt-get -qq -y clean

RUN  cd /usr/bin \
	&& curl -sSL https://github.com/arduino/arduino-cli/releases/download/0.11.0/arduino-cli_0.11.0_Linux_64bit.tar.gz | tar -zxf - > /usr/bin/arduino-cli \
	&& chmod +x arduino-cli \
	&& arduino-cli core update-index --additional-urls http://arduino.esp8266.com/stable/package_esp8266com_index.json \
	&& arduino-cli core search esp8266 --additional-urls http://arduino.esp8266.com/stable/package_esp8266com_index.json \
	&& arduino-cli core install esp8266:esp8266 --additional-urls http://arduino.esp8266.com/stable/package_esp8266com_index.json \
	&& arduino-cli core list

# Install avahi pieces required
RUN mkdir -p /var/run/dbus
COPY supervisor.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisord

ENTRYPOINT ["/usr/bin/env"]
CMD supervisord -c /etc/supervisor/supervisord.conf
