#!/usr/bin/env python3

import requests 
import os
# get headers information
url = 'http://google.com'

# os.environ['http_proxy'] =  'http://127.0.0.1:1080'
# os.environ['https_proxy'] =  'http://127.0.0.1:1080'

try:
  res = requests.get(url, timeout=10)
  if res.status_code == 200:
    print('bingo')
except Exception as e:
  print(e)


