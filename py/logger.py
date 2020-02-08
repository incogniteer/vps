import logging

# reusable logger function
# import sys + StreamHanlder(sys.stdout) to stdout, default stderr
def logger(logPath="d:\py\log", logFile="log"):
    logging.basicConfig(level=logging.DEBUG,
                        format="%(asctime)s:\t%(levelname)s:\t%(message)s",
                        datefmt='%Y-%m-%d %H:%M:%S',
                        handlers=[
                        logging.FileHandler("{0}\{1}.txt".format(logPath, logFile), mode='w'),
                        logging.StreamHandler(),
                        ])

    return logging
