export TOPDIR=${CURDIR}

include Makefile.in

libs-y= 
libs-${CONFIG_GMP} += gmp
libs-${CONFIG_PCRE} += pcre 
libs-${CONFIG_LIBUBOX} += libubox 
libs-${CONFIG_ZLIB} += zlib 
libs-${CONFIG_QDECODER} += qdecoder 
libs-${CONFIG_LIBPCAP} += libpcap

apps-y=
apps-${CONFIG_BASE} += base 
apps-${CONFIG_BUSYBOX} += busybox 

# Network Applications
apps-${CONFIG_NETWORK} += network 
apps-${CONFIG_IPTABLES} += iptables 
apps-${CONFIG_NET_SNMP} += net-snmp
apps-${CONFIG_OPENSSL} += openssl 
apps-${CONFIG_OPENSSH} += openssh 
apps-${CONFIG_DROPBEAR} += dropbear 
apps-${CONFIG_STRONGSWAN} += strongswan 
apps-${CONFIG_HOTPLUG2} += hotplug2 
apps-${CONFIG_NTPCLIENT} += ntpclient 
apps-${CONFIG_LIGHTTPD} += lighttpd 
apps-${CONFIG_UDHCPD} += udhcpd
apps-${CONFIG_WEBADMIN} += webadmin 
apps-${CONFIG_MOSQUITTO} += mosquitto 

# Wireless applications
apps-${CONFIG_WIRELESS_TOOLS} += wireless_tools 
apps-${CONFIG_WIFI} += wifi 
apps-${CONFIG_AP} += ap

# Configuration Utilities
apps-${CONFIG_LUA} += lua 
apps-${CONFIG_UCI} += uci 

# Debugging Utilities
apps-${CONFIG_TCPDUMP} += tcpdump 

LIBS=${libs-y}
APPS=${apps-y}

all: install_apps
	
phase1: build_libs

config_libs: 
	[ -d ${BUILDDIR} ] || mkdir -p ${BUILDDIR}
	for lib in $(LIBS); do \
		[ -d ${BUILDDIR}/$$lib ] || (cd ${BUILDDIR}; tar xvfz ${PKGDIR}/$$lib-pkg.tar.gz);\
		make -C ${BUILDDIR}/$$lib config DESTDIR=${DESTDIR} ; \
	done

config_apps: install_libs
	[ -d ${BUILDDIR} ] || mkdir -p ${BUILDDIR}
	for app in $(APPS); do \
		if [ ! -d ${BUILDDIR}/$$app ]; then \
			(cd ${BUILDDIR}; tar xvfz ${PKGDIR}/$$app-pkg.tar.gz) \
		fi;\
		make -C ${BUILDDIR}/$$app config DESTDIR=${DESTDIR} ; \
	done
	
build_libs:  config_libs
	for app in $(LIBS); do \
		make -C ${BUILDDIR}/$$app build ; \
	done

build_apps:  config_apps
	for app in $(APPS); do \
		make -C ${BUILDDIR}/$$app build ; \
	done

install_libs: build_libs
	if [ -d ${DESTDIR} ]; then \
		rm -rf ${DESTDIR}\* ;\
	else \
		mkdir -p ${DESTDIR} ;\
	fi
	for app in $(LIBS); do \
		make -C ${BUILDDIR}/$$app install DESTDIR=${DESTDIR} ; \
	done

install_apps: build_apps
	if [ -d ${DESTDIR} ]; then \
		rm -rf ${DESTDIR}\* ;\
	else \
		mkdir -p ${DESTDIR} ;\
	fi
	for app in $(APPS); do \
		make -C ${BUILDDIR}/$$app install DESTDIR=${DESTDIR} ; \
	done
	tools/make_image ${DESTDIR} rootfs.img

#	if [ -d ${DESTDIR} ]; then \
		rm -rf ${DESTDIR} ;\
	fi

clean:
	for app in $(LIBS) $(APPS); do \
		make -C ${BUILDDIR}/$$app clean ; \
	done

distclean:
	rm -rf ${BUILDDIR}

