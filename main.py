from flask import Flask, jsonify
import multiprocessing
import socket
from subprocess import Popen, PIPE

app = Flask(__name__)

def return_IP():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP_add = s.getsockname()[0]
        #can be unreachable
    except:
        IP_add = '127.0.0.1' #localhost
    finally:
        s.close()
    return IP_add
    
    
def return_pub_IP():
    with Popen(["dig", "+short", "myip.opendns.com", "@resolver1.opendns.com"], stdout=PIPE) as proc:
        IP_address = str(proc.stdout.read())
        IP = IP_address[2:-3]
    return IP

def return_mem():
    with Popen(["awk", "/MemTotal/ {print $2}", "/proc/meminfo"], stdout=PIPE) as proc:
        memStr = str(proc.stdout.read())
        mem = memStr[2:-3]
    return mem


@app.route('/status')
def details():
    a = {
        "hostname": socket.gethostname(),
        "ip address": return_IP(),
        "public ip": return_pub_IP(),
        "cpus": multiprocessing.cpu_count(),
        "memory": return_mem()
    }
    return jsonify(a)


app.run(host='0.0.0.0', port=8080)
