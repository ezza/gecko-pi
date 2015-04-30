gecko-pi
========

Easily set up a fresh new Raspberry Pi for use with Geckoboard.

For more information check out our [blog post](http://www.geckoboard.com/blog/geckoboard-and-raspberry-pi).

how to
======

Make sure your Pi is online. Open a terminal emulator, and run these two commands:

```bash
export DASHBOARD_URL=https://example.geckoboard.com/dashboard/AAABBBCCDDD 

curl -L https://raw.github.com/ezza/gecko-pi/master/install.sh  | bash
```

Done!

