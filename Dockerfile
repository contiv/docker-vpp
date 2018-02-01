ARG BUILDER_IMAGE
FROM ${BUILDER_IMAGE} as builder

RUN cd /vpp/build-root \
 && bash -c "tar -czvf vpp-debs.tar.gz {vpp,vpp-plugins,vpp-lib}_$(git describe --tags | sed -e s/-/~/2 -e s/^v//)_amd64.deb"

FROM ubuntu:16.04

ENV LD_PRELOAD_LIB_DIR /opt/ldpreload

COPY --from=builder /vpp/build-root/vpp-debs.tar.gz /tmp/vpp-debs.tar.gz
COPY --from=builder /vpp/build-root/install-vpp-native/vpp/lib64/libvcl_ldpreload.so.0.0.0 ${LD_PRELOAD_LIB_DIR}/


RUN apt-get update \
 && apt-get install -y libssl1.0.0 libnuma1 \
 && tar -C /tmp/ -xvzf /tmp/vpp-debs.tar.gz \
 && dpkg -i /tmp/vpp-lib_*.deb /tmp/vpp_*.deb /tmp/vpp-plugins_*.deb \
 && rm -rf /tmp/*.deb /tmp/vpp-debs.tar.gz /var/lib/apt/lists/*
