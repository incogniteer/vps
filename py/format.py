#!/usr/bin/env py

import decimal
import random

width = 10
precision = 4
value = decimal.Decimal('12.345678')
number = random.randint(100000, 100000000)
ascii = random.randint(32,126)
# 随机小数，round控制精度
float = random.uniform(0,1)
text = "This is python!"

print("f'result: {value:{width}.{precision}}': ", f'result: {value:{width}.{precision}}')

print("f'{number:b}': ", f'{number:b}')
print("f'{number:o}': ", f'{number:o}')
print("f'{number:x}': ", f'{number:x}')
print("f'{number:X}': ", f'{number:X}')
print("f'{number:f}': ", f'{number:f}')
print("f'{number:e}': ", f'{number:e}')
print("f'{str(number):s}': ", f'{str(number):s}')
print("Random ASCII printable characters: f'{ascii:c}': ", f'{ascii:c}')

print(f'{float:12.6f}')
print(f'{float:-12.6f}')
print("center format: f'{text:*^30s}': ", f'{text:*^30s}')
print("left format: f'{text:-<30s}': ", f'{text:-<30s}')
print("right format: f'{text:_>30s}': ", f'{text:_>30s}')
