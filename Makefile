start:
	sh ./bin/commands/start.sh
build:
	sh ./bin/commands/update_cert.sh
	sh ./bin/commands/trust_cert.sh
	sh ./bin/commands/update_hosts.sh
	sh ./bin/commands/start.sh
update_hosts:
	sh ./bin/commands/update_hosts.sh
update_ssl:
	sh ./bin/commands/update_cert.sh
	sh ./bin/commands/trust_cert.sh
	sh ./bin/commands/update_hosts.sh
trust_ssl:
	sh ./bin/commands/trust_cert.sh
