gecko-pi
========

Easily set up a fresh new Raspberry Pi for use with Geckoboard.

For more information check out this [blog post](http://www.geckoboard.com/blog/geckoboard-and-raspberry-pi).

how to
======

Make sure your Pi is online. Open a terminal emulator, and run these two commands:

```bash
export DASHBOARD_URL=https://example.geckoboard.com/dashboard/AAABBBCCDDD 

curl -L https://raw.githubusercontent.com/ezza/gecko-pi/master/install.sh  | bash
```

Done!


Problems?
======
Try the cron branch which runs chromium every minute if it's not already running. It will also attempt to ensure your screen resolution is 1080p.

```
curl -L https://raw.githubusercontent.com/ezza/gecko-pi/cron/install.sh  | bash
```
