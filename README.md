A fig-env docker image with
----------------------------
- Java 8
- Chrome
- Selenium
- Chromedriver
- XVFB for headless chrome

To Use
----------------------------
```
export DISPLAY=:99
sudo /etc/init.d/xvfb start
[Run your tests, gradle/ruby .. + ]
sudo /etc/init.d/xvfb stop [optional]
```