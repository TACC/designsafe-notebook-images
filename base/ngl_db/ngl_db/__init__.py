# Establishes connection to NGL database from MySQL Workbench
import pymysql
def connect():
    try:
        return(pymysql.connect(user='dspublic', password='R3ad0nlY', host='129.114.52.174', port=3306, db='sjbrande_ngl_db'))
    except:
        pass
