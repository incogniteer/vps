#!/usr/bin/env py

import datetime

today = datetime.datetime.today()
print('__str__: ', today, sep='\n')
print('repr(): ', repr(today), sep='\n')
print('obj.__repr__(): ', today.__repr__(), sep='\n')
print()
print(today.strftime('%Y-%m-%d'))
print()

now = datetime.datetime.now()
print('__str__: ', now, sep='\n')
print('repr(): ', repr(now), sep='\n')
print('obj.__repr__(): ', now.__repr__(), sep='\n')
print()
print(now.strftime('%H:%M:%S'))
