# Establishes connection to NGL database from MySQL Workbench
import pymysql
def connect():
    try:
        return(pymysql.connect(user='dspublic', password='R3ad0nlY', host='129.114.58.189', port=3306, db='post_earthquake_recovery'))
    except:
        pass
