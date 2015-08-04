FROM resin/rpi-raspbian:latest

RUN apt-get update && apt-get install -y hostapd isc-dhcp-server iptables wpasupplicant && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY hostapd.conf /etc/hostapd/hostapd.conf
COPY hostapd /etc/default/hostapd
COPY dhcpd.conf /etc/dhcp/dhcpd.conf 
COPY isc-dhcp-server /etc/default/isc-dhcp-server
COPY interfaces /etc/network/interfaces
COPY sysctl.conf /etc/sysctl.conf

RUN iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
RUN iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
RUN iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT 

RUN sh -c "iptables-save > /etc/iptables.ipv4.nat"

RUN update-rc.d hostapd enable
RUN update-rc.d isc-dhcp-server enable 
