#!/usr/bin/python
# -*- coding: utf-8 -*-
# Develop by Javier Riveros


import psycopg2
import sys
import os
import decimal



#define check valid ip address
def validip(ip):
    return ip.count('.') == 3 and  all(0<=int(num)<256 for num in ip.rstrip().split('.'))

#define database conexion

def Dbconection():
    try:
        con = psycopg2.connect(database='snpp02',user='snpp02',password='2013#Cantv',host='10.1.189.72',port='10002')
    except Exception, e:
        print "###### Problem trying to connect to database ######"
    else:
        return con


#config variables
interface='eth0'
con = None

#get local ip address

fd=os.popen("ifconfig %s | grep inet\ addr\: | awk '{ print $2 }' | cut -d: -f2" % interface)
localip = fd.read()[:-1]
#localip = '161.196.36.181'
#localip = '192.168.88.13'
fd.close()
print "######Local ip#######"
print localip

try:
    print "######Remote ip#######"
    print sys.argv[1]
    argument=sys.argv[1]
except:
    print '###### Check your input invalid argument ######'
    sys.exit()  

if validip(argument):
    ipserver = sys.argv[1]
    ipvalid = True
else:
    if argument.find('.')==-1:
        validarg = sys.argv[1]
        ipserver=localip
        ipvalid = False
    else:
        print '###### Please check command, Invalid IP address ######'
        sys.exit()
    
#print validarg



#querys

query_ip="select * from astsipserver where serveraddress='"+ipserver+"'"
print "###### Checking ###### "

if  ipvalid and localip==ipserver:
    db = Dbconection()
    cur = db.cursor()
    try:
    	cur.execute(query_ip)
    	result = cur.fetchone()
	astrow=cur.rowcount
    	print result
	#check here if there are no server on the system !
    	if astrow != 0:
		status=result[3]
    		sensed=result[4]
	else:
		print "Server You Want take off is not on the systems"
		sys.exit(1)
    except psycopg2.DatabaseError, e:
        print 'Error %s' % e
        sys.exit(1)

    if status==0 and sensed==1:
        print "###### Server is Down and Script was run, if you want to start service try START argument  ######"   

    if status==1 and sensed==1:
        print "###### Server is up and script was run NOTICE is not a normal Behavior ######"

    elif ((status==1 and sensed==0) or (status==0 and sensed==0)):
	# i will put agents on 3, shutdown asterisk and update status on 0 and sensed on 1 
        query_agendid="select agentid from agents where ipaddress='"+ipserver+"'"
        #print query_agendid
        agentid_cur= db.cursor()
        agentid_cur.execute(query_agendid)
        result_agentid = agentid_cur.fetchall()
	#print result_agentid
	rows=agentid_cur.rowcount
	#print rows
	if agentid_cur.rowcount != 0:
		for ids in result_agentid:
            		id = str(ids[0])
            		try:
                		agentid_cur.execute("update agent_groups set status=3 where agentid='%s'"%(id))
                		db.commit()
            		except psycopg2.DatabaseError, e:
                		print 'Error %s' % e
                		sys.exit(1)
		print "###### We have been Unregister: %s agents on server: %s  ######"% (rows,ipserver)
        else:
                print "###### There are no Agents Register on this server : "+ipserver
                #sys.exit(1)

        print ids[0]
        #stopast = os.popen("sudo /etc/init.d/asterisk stop")
        #output = stopast.read()[:-1]
	print "###### Asterisk Says ######"
	#print output
        #stopast.close()
	#update table on astsipserver	
        ast_status_cur= db.cursor()
	sipserver=str(localip)
        ast_status_cur.execute("update astsipserver set status=0 ,sensed=1 where sipaddress='%s'"%(sipserver))
        db.commit()
	print "###### node is out of callcenter :"+sipserver
    db.close()

elif  ipvalid and localip!=ipserver:
    db = Dbconection()
    cur = db.cursor()
    try:
        cur.execute(query_ip)
        result = cur.fetchone()
	astrow=cur.rowcount
        #print result
        #check here if there are no server on the system !
        if astrow != 0:
                status=result[3]
                sensed=result[4]
        else:
                print "###### Server You Want take off is not on the systems ######"
                sys.exit(1)

    except psycopg2.DatabaseError, e:
        print 'Error %s' % e
        sys.exit(1)

    if status==0 and sensed==1:
        print "###### Server is Down and Script was run, if you want to start service try START argument  ######"
    if status==1 and sensed==1:
        print " ###### Server is up and script was run NOTICE is not a normal Behavior #######"

    elif ((status==1 and sensed==0) or (status==0 and sensed==0)):
        # block 2
        # i will put agents on 3, and update status on 0 and sensed on 1" 
        query_agendid="select agentid from agents where ipaddress='"+ipserver+"'"
        #print query_agendid
        agentid_cur= db.cursor()
        agentid_cur.execute(query_agendid)
        result_agentid = agentid_cur.fetchall()
	rows=agentid_cur.rowcount
        # print rows
        if agentid_cur.rowcount != 0:
                for ids in result_agentid:
                        id = str(ids[0])
                        try:
                                agentid_cur.execute("update agent_groups set status=3 where agentid='%s'"%(id))
                                db.commit()
                        except psycopg2.DatabaseError, e:
                                print 'Error %s' % e
                                sys.exit(1)
                print "###### We have been Unregister: %s agents on server: %s  ######"% (rows,ipserver)
        else:
                print "###### There are no Agents Register on this server: %s ######" % (ipserver)
                #sys.exit(1)
        
        #print ids[0]
        #update table on astsipserver   
        ast_status_cur= db.cursor()
        sipserver=str(ipserver)
        try:
            ast_status_cur.execute("update astsipserver set status=0 ,sensed=1 where sipaddress='%s'"%(sipserver))
            db.commit()
        except psycopg2.DatabaseError, e:
            print 'Error %s' % e
            sys.exit(1)
        print "Node is out of callcenter : "+sipserver
    db.close()

elif validarg=='start':
    #startast = os.popen("/etc/init.d/asterisk start")
    #print "###### Asterisk Says ######"
    #output = startast.read()[:-1]
    #print output
    #startast.close()
    #update table on astsipserver   
    db = Dbconection()
    cur = db.cursor()
    ast_status_cur= db.cursor()
    sipserver=str(localip)
    ast_status_cur.execute("update astsipserver set status=1 ,sensed=0 where sipaddress='%s'"%(sipserver))
    db.commit()
    db.close()
    print "###### Node is up : %s ######" % (sipserver)


