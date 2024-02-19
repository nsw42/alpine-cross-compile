#! /bin/sh

cat > /etc/profile.d/go_cross.sh <<EOF
export PKG_CONFIG_PATH=/usr/lib/$(xx-info triple)/pkgconfig
export PKG_CONFIG_PATH=/usr/lib/$(xx-info triple)/pkgconfig
export TARGETPLATFORM=${TARGETPLATFORM}
export CC=$(xx-info triple)-gcc
export LD_LIBRARY_PATH=/usr/lib/$(xx-info triple)
EOF

echo "source /etc/profile.d/go_cross.sh" >> /root/.bashrc

. /etc/profile.d/go_cross.sh
apt-get install -y build-essential
xx-apt-get install -y gcc binutils
