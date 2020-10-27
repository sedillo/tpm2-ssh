FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y vim wget curl git \
    autoconf-archive   libcmocka0   libcmocka-dev   procps   iproute2   build-essential   git   pkg-config   gcc   libtool   automake   libssl-dev   uthash-dev   autoconf   doxygen   libjson-c-dev   libini-config-dev   \
     autoconf automake libtool pkg-config gcc libssl-dev uuid-dev python-yaml \
     automake make gcc libsqlite3-dev autoconf-archive python3.7 python3-pip libyaml-dev \
     libcurl4-gnutls-dev

RUN mkdir -p /tpm2
WORKDIR /tpm2

RUN git clone https://github.com/tpm2-software/tpm2-tss
WORKDIR tpm2-tss
RUN git checkout 3.0.1
RUN ./bootstrap && ./configure && make -j4 && make install
RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/
RUN ldconfig
WORKDIR ..

RUN git clone https://github.com/tpm2-software/tpm2-tools
WORKDIR tpm2-tools
RUN git checkout 4.3.0
RUN ./bootstrap && ./configure && make -j4 && make install
WORKDIR ..

RUN git clone https://github.com/tpm2-software/tpm2-pkcs11
WORKDIR tpm2-pkcs11
RUN git checkout 1.4.0
RUN python3.7 -m pip install pip
RUN ./bootstrap && ./configure && make -j4 && make install
WORKDIR tools
RUN python3.7 -m pip install .
RUN python3.7 -m pip install cffi
RUN python3.7 setup.py install

ARG USERPIN=myuserpin
ARG SOPIN=mysopin

WORKDIR /tpm2
RUN touch init.sh
RUN chmod +x ./init.sh
RUN echo "#!/bin/bash\nset -x\ncd voldir\ntpm2_ptool init\ntpm2_ptool addtoken --pid=1 --label=label --sopin=${SOPIN} --userpin=${USERPIN}\ntpm2_ptool addkey --algorithm=rsa2048 --label=label --userpin=${USERPIN}\nssh-keygen -D /usr/local/lib/libtpm2_pkcs11.so | tee my.pub\n" > init.sh

ENTRYPOINT ["/bin/sh", "-c","tail -f /dev/null"]
