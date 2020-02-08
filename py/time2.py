#!/usr/bin/env py

import time
import datetime
import random
from timeit import default_timer as timer

############################################################
# 时间转换成秒数
def get_sec(time_str):
  """Get seconds from time: H:M:S"""
  h, m, s = time_str.split(':')
  return int(h) * 3600 + int(m) * 60 + int(s)

def get_sec2(t):
  return sum(int(x) * 60 ** i for i,x in
  enumerate(reversed(t.split(':'))))

t = '02:19:29'
print(get_sec(t))
print(get_sec2(t))

############################################################
# 秒数转换成时间
"""
def get_time(s):
  h = s // 3600
  m = s % 3600 // 60
  s = s % 60
  if h > 0:
    return f'{s:.0f}hours,{s:.0f}mins,{s:.3f}s'
  elif m > 0:
    return f'{s:.0f}mins,{s:.3f}s'
  else:
    return f'{s:.3f}s'

s1 = 35.3
print(get_time(s1))
s2 = 888.232
print(get_time(s2))
s3 = 88888.23232
print(get_time(s3))
"""

############################################################
s = 888
# time.gmtime return time.struct_time
t1 = time.strftime('%H:%M:%S', time.gmtime(s))
print(t1)

t2 = datetime.timedelta(seconds=s)
print(t2)

print('{:02}:{:02}:{:02}'.format(s//3600, s%3600//60, s%60))
print(f'{s//3600:02}:{s%3600//60:02}:{s%60:02}')

############################################################
def timer2(s):
  # rand_time = random.uniform(3.23, 8888.232)
  def get_time2(s):
    h = s // 3600
    m = s % 3600 // 60
    s = s % 60
    if h > 0:
      return f'{s:.0f}hours,{s:.0f}mins,{s:.3f}s'
    elif m > 0:
      return f'{s:.0f}mins,{s:.3f}s'
    else:
      return f'{s:.3f}s'

  return get_time2(s)

if __name__ == '__main__':
    start = timer()
    for i in range(2):
      time.sleep(random.uniform(1.2,3.3))
      end = timer()
      s = end - start
      print(timer2(s))
