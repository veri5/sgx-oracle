FROM ubuntu:22.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  gramine nodejs \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

RUN gramine-sgx-gen-private-key

COPY ./node.manifest.template .

RUN gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu node.manifest.template node.manifest \
    && gramine-sgx-sign --key enclaive-key.pem --manifest node.manifest --output node.manifest.sgx \
    && gramine-sgx-get-token --output node.token --sig node.sig

VOLUME ./data/ /data/

EXPOSE 3000

ENTRYPOINT [ "/usr/local/bin/gramine-sgx", "node" ]