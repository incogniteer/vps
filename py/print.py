#!/usr/bin/env python3

import sys
import time
import logging
import random

# print on the same line, use end=\r
"""
for i in range(10):
  print("Loading" + "." * i, end='\r')
  time.sleep(1)
"""

"""
# 方法二：ANSCI escape sequence
for i in range(10):
  print("Loading" + "." * i)
  sys.stdout.write('\x1b[F') # cursor up one line
  time.sleep(1)
"""


"""
# print on the same line, use end=\r
# not work, if shorter than before
# 会一直出现: Loading..........
for i in range(10):
  print("Loading........."[:-i], end='\r')
  time.sleep(1)
"""

"""
# 修正方法使用ANSCI ESCAPE sequence
for i in range(10):
  print("Loading........."[:-i], end='\r')
  time.sleep(1)
  sys.stdout.write('\033[K') # clear to end of line
"""

# 意外发现，从下往上输出 end=\r
for i in range(10):
  print("Loading........."[:-i], end='\r')
  sys.stdout.write('\x1b[F') # cursor up one line
  time.sleep(1)
  sys.stdout.write('\033[K') # clear to end of line

for i in range(10):
  print("Loading........."[:-i])
  sys.stdout.write('\x1b[F') # cursor up one line
  time.sleep(1)
  sys.stdout.write('\033[K') # clear to end of line

for i in range(10):
  print("Loading........."[:-i], end='\r')
  time.sleep(1)
  #sys.stdout.write('\033[F') # ANSI escape sequence: cursor up one line
  #sys.stdout.write('\033[2K\033[1G')
  #sys.stdout.write('\033[K') # Clear to the end of line
