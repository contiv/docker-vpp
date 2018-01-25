FROM ubuntu:16.04 as builder

RUN apt-get update && apt-get install -y git build-essential software-properties-common sudo && \
            add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
            apt-get update && apt-get install -y gcc-7 && \
            cd /usr/bin/ && rm gcc && ln -s gcc-7 gcc && \
            git clone https://gerrit.fd.io/r/vpp /vpp

ADD build.env /

RUN . /build.env && cd /vpp && git pull && git checkout ${VPP_COMMIT} && \
    UNATTENDED=y make install-dep bootstrap pkg-deb &&  \
    cd build-root && tar -zcf vpp-debs.tar.gz ./*.deb

FROM ubuntu:16.04

COPY --from=builder /vpp/build-root/vpp-debs.tar.gz /tmp/vpp-debs.tar.gz

RUN apt-get update && apt-get install -y libssl1.0.0 libnuma1 && \
    tar -C /tmp/ -xzf /tmp/vpp-debs.tar.gz  && \
    dpkg -i /tmp/vpp-lib_*.deb /tmp/vpp_*.deb /tmp/vpp-plugins_*.deb && \
    rm -f /tmp/*.deb /tmp/vpp-debs.tar.gz
