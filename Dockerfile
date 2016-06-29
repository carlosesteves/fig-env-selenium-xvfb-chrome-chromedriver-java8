FROM te-docker.docker-registry.tools.springer-sbm.com/fig-env-java-8

MAINTAINER Joviano Dias <joviano.dias@springer.com>

# Bits from
# Jessica Frazelle <jess@docker.com>
# https://gist.github.com/jterrace/2911875 + Others

RUN apt-get update -y -q
RUN apt-get install -y -q unzip xvfb psmisc

#=================================
# Chrome
#=================================
ADD https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb /src/google-talkplugin_current_amd64.deb
RUN echo 'deb http://httpredir.debian.org/debian testing main' >> /etc/apt/sources.list && \
	apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	hicolor-icon-theme \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libv4l-0 \
	-t testing \
	fonts-symbola \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	--no-install-recommends \
	&& dpkg -i '/src/google-talkplugin_current_amd64.deb' \
	&& apt-get purge --auto-remove -y curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /src/*.deb
COPY local.conf /etc/fonts/local.conf

#==================
# Chrome Webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.22
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

#=================================
# Start XVFB on :99
#=================================
ENV DISPLAY :99
CMD ["/etc/init.d/xvfb","start"]