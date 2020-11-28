## Author mika.nokka1@gmail.com  January 2018, Nov 2020


from flask import Flask
import logging, sys
import logging.config
from logging import FileHandler
from logging.handlers import RotatingFileHandler
from logging import Formatter
import os
from flask import request # for p arameter handling

import redis
import os.path
import os
from redis import Redis, RedisError

# loggins possibilities
# print --> docker own logging system
# logger --> own logfile



app=Flask(__name__)

redis = redis.Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

runtime="NA"
loglevel = logging.DEBUG  
#logfile="/tmp/flask.log"
user="NA"
pwd="NA"


# one could do several redis request in case of failures....
def get_hits():
    return redis.incr('hits')

def main(argv):
    #logging.basicConfig(filename=logfile,level=loglevel) 
    
    shellvar1=os.environ['SHELLLOGFILE']
    shellvar2=os.environ['CONTAINERDIR']
    BUILDDATE=os.environ['BUILDDATE']
    print ("===> Using shell variable SHELLLOGFILE:{0}".format(shellvar1))
    print ("===> Using shell variable CONTAINERDIR:{0}".format(shellvar2))    
    print ("===> App image was build on {0}".format(BUILDDATE))   
    
    # created in dockerfile
    logfile=shellvar2+"/"+shellvar1
    #logfile="flaskinlog"
    
    # if file created in dockerfile, logging starts ok without this
    #needed to get logging inside container to work, noidea why
    #with open (logfile ,"a") as myfile:
    #    data="sdfsafasf" 
    #    myfile.write(data)
    
    print("===> Host Flask server logfile: {0}".format(logfile))
    
    handler = RotatingFileHandler(logfile, maxBytes=10000, backupCount=1)
    handler.setLevel(loglevel)
    handler.setFormatter(Formatter('%(asctime)s %(levelname)s: %(message)s '))
    
    app.logger.addHandler(handler)
    
    app.logger.warning ("-- App image was build on{0} --".format(BUILDDATE))
    if (runtime=="SERVER"): 
        app.logger.warning  ("--Python starting standalone Flask server--") 
        app.run(debug=False, host='0.0.0.0')
    if (runtime=="uWSGI"):
        app.logger.warning ("-- uWSGI running Flask server--") 
        print ("-- uWSGI running Flask server--") 

    
   
         
@app.route('/')
def slash():
    shellvar1=env_var = os.environ 
    app.logger.warning ("--Just the test page xxxxx-") #error goes to uWSGI console log too
    print("Printing: Test page section xxxx") # goes uWSGI console log
    return "Returning test page creation message xxxx {0}\n".format(shellvar1)


@app.route('/test')
def hello_world():
    app.logger.warning ("--Just the test page-") 
    print("Printing: Test page section") 
    hits=get_hits()
    return "Returning test page creation message, hits:{0}\n".format(hits)

@app.route('/cat')
def cat():
    app.logger.warning("--Cat section-") 
    print("==>Printing: Cat page section") 
    return "Returning Cat page message: MIU\n"

@app.route('/logs')
def logs():
    command="ls -la"
    print("****** EXECUTING:" + command)
    #result=os.system(command)
    result = os.popen(command).read()
    app.logger.warning("--Logs section-:{0}".format(result)) 
    print("==> Logs section:{0}".format(result)) 
    webresult= result.replace("\n", "<br>")
    return (" Logs section <br>:{0}".format(webresult))        
 
     
if __name__ == "__main__":
    runtime="SERVER"
    print("==> SERVER RUNTIME")
    main(sys.argv[1:])

else:
    runtime="uWSGI"
    print("==> uWSGI RUNTIME : {0}".format(__name__))
    main(sys.argv[1:])   

# needed?
application = app