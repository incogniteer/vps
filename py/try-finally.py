#!/usr/bin/env python3

from time import sleep
counter = 0
for i in range(10):
  try:
    counter += 1
    sleep(0.5) 
  except:
    print('error')
  else:
    print('wrong')
#  finally:
#    print(f'finally {counter}')

# finally不能放在try结构，必须单独打印跟for同indent
#  print(f'finally {counter}')
print(f'finally {counter}')
