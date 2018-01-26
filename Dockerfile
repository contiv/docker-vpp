FROM ubuntu:16.04 as builder

RUN apt-get update \
 && apt-get install -y \
    git build-essential software-properties-common sudo \
 && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && apt-get update \
 && apt-get install -y gcc-7 \
 && cd /usr/bin/ \
 && rm gcc \
 && ln -s gcc-7 gcc \
 && git clone https://gerrit.fd.io/r/vpp /vpp

ADD build.env /

RUN . /build.env \
 && cd /vpp \
 && git pull \
 && git checkout ${VPP_COMMIT} \
 && UNATTENDED=y make install-dep bootstrap pkg-deb \
 && cd build-root \
 && bash -c "tar -czvf vpp-debs.tar.gz {vpp,vpp-plugins,vpp-lib}_$(git describe --tags | sed -e s/-/~/2 -e s/^v//)_amd64.deb"

FROM ubuntu:16.04

COPY --from=builder /vpp/build-root/vpp-debs.tar.gz /tmp/vpp-debs.tar.gz
COPY --from=builder /vpp/build-root/install-vpp-native/vpp/lib64 /opt/ldpreload

RUN apt-get update \
 && apt-get install -y libssl1.0.0 libnuma1 \
 && tar -C /tmp/ -xvzf /tmp/vpp-debs.tar.gz \
 && dpkg -i /tmp/vpp-lib_*.deb /tmp/vpp_*.deb /tmp/vpp-plugins_*.deb \
 && rm -rf /tmp/*.deb /tmp/vpp-debs.tar.gz /var/lib/apt/lists/*
