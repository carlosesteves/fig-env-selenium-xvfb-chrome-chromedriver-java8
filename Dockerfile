FROM te-docker.docker-registry.tools.springer-sbm.com/fig-env-java-8
MAINTAINER Joviano Dias <joviano.dias@springer.com>

ENV LAST_UPDATED 2017-01-30

# Bits from
# Jessica Frazelle <jess@docker.com>
# https://gist.github.com/jterrace/2911875 + Others

RUN apt-get update -y -q && apt-get install -y apt-utils && apt-get upgrade -y
RUN apt-get install -y -q unzip xvfb psmisc curl build-essential

#==================
# Postgres
#==================
RUN apt-get install -y postgresql postgresql-contrib

#=================================
# Node
#=================================
RUN apt-get purge --auto-remove -y node \
  && curl -sSL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get update -y \
  && apt-get install -y nodejs

#=================================
# Chrome
#=================================
ADD https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb /src/google-talkplugin_current_amd64.deb
RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	hicolor-icon-theme \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libv4l-0 \
    ttf-ancient-fonts \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	--no-install-recommends \
	&& dpkg -i '/src/google-talkplugin_current_amd64.deb' \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /src/*.deb
COPY local.conf /etc/fonts/local.conf

#==================
# Chrome Webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.25
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

#========================
# Selenium Configuration
#========================
COPY config.json /opt/selenium/config.json

#=================================
# Chrome Launch Script Modication
#=================================
COPY google-chrome-launcher /opt/google/chrome/google-chrome
RUN chmod +x /opt/google/chrome/google-chrome

# Following line fixes
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

#=================================
# Install XVFB Init Script
#=================================
ADD xvfb_init /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
ADD xvfb-daemon-run /usr/bin/xvfb-daemon-run
RUN chmod a+x /usr/bin/xvfb-daemon-run

## XVFB does not autostart, start it on :99
CMD (service xvfb start; export DISPLAY=:99;)

CMD service postgresql start
