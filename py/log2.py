#!/usr/bin/env py

import logging
import datetime

def logger2():
  logPath = '/home/debian/py/log'
  logFile = 'log'
  date = datetime.datetime.today().strftime('%Y-%m-%d')

  # 默认stderr，重定向到stdout方法：                    
  # import sys + StreamHanlder(sys.stdout) to stdout, default stderr
  logging.basicConfig(level=logging.DEBUG,
                      format="%(asctime)s:\t%(levelname)s:\t%(message)s",
                      datefmt='%Y-%m-%d %H:%M:%S',
                      handlers=[
                          logging.FileHandler(f'{logPath}/{logFile}-{date}.log', mode='w'),
                          logging.StreamHandler(),
                          ])

  # get the logger
  return logging.getLogger()

logger = logger2()
class Pizza():
    def __init__(self, name, price):
        self.name = name
        self.price = price
        logger.debug("Pizza created: {} (${})".format(self.name, self.price))

    def make(self, quantity=1):
        logger.info("Made {} {} pizza(s)".format(quantity, self.name))

    def eat(self, quantity=1):
        logger.error("Ate {} {} pizza(s)".format(quantity, self.name))

if __name__ == '__main__':
    pizza_01 = Pizza("artichoke", 15)
    pizza_01.make()
    pizza_01.eat()
    pizza_01.make(10)
    pizza_02 = Pizza("artichoke", 19)
    pizza_02.make()

    # 测试遍历出错捕获exception输入异常
    for name in ['John', 'Mary', 'Tim', 'Jim', 'Lyn', 3.14]:
      try:
        print(name + '.')
      except Exception as e:
        logger.error("Error!" + ": " + repr(e))
