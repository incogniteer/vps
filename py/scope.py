#!/usr/bin/env python3

# counter 放在for循环内会出错，没迭代一次都被重置
print('counter在for 循环内初始化：')
for i in range(10):
  counter = 0
  try:
    counter += 1

    if 1:
      print(counter)

  except:
    pass

print('counter在for 循环外初始化：')
# counter 放在for循环外则正常
counter = 0
for i in range(10):
  try:
    counter += 1

    if 1:
      print(counter)

  except:
    pass
