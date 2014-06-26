#!/bin/bash
		cd
		cd /var/lib/asterisk/agi-bin/callcenter/


		echo "\n****************************************************"
		echo "***********Excute Presence screen*******************"
		echo "****************************************************"
		sudo screen -dmS Presence java -cp lib/asterisk-java-1.0.0.M3.jar:lib/postgresql-9.1-903.jdbc4.jar:. com.capanicus.callcenter.PresenceMonitor
		sleep 1


		echo "****************************************************"
		echo "***********Excute Billing screen*******************"
		echo "****************************************************"
		sudo screen -dmS Billing java -cp lib/asterisk-java-1.0.0.M3.jar:lib/postgresql-9.1-903.jdbc4.jar:. com.capanicus.callcenter.LiveCallsMonitor
		sleep 1


		echo "****************************************************"
		echo "***********Excute AGI screen*******************"
		echo "****************************************************"
		sudo screen -dmS AGI java -cp lib/asterisk-java-1.0.0.M3.jar:lib/postgresql-9.1-903.jdbc4.jar:fastagi-mapping.properties:. -Xms1024m -Xmx1024m org.asteriskjava.fastagi.DefaultAgiServer
		sleep 1

		echo "****************************************************"
		echo "******************View all screen*******************"
		echo "****************************************************"
		sudo screen -list

		/usr/local/bin/cc_monitor.py start