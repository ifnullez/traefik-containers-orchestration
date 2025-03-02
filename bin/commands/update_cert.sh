#!/bin/bash
openssl req -config ./ssl/sites.conf -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./ssl/sites.key -out ./ssl/sites.crt
