FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl gramine nodejs \
  && rm -rf /var/lib/apt/lists/* /usr/share/keyrings/*

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/gramine.list && \
  curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/intel-sgx.list

WORKDIR /app/

RUN gramine-sgx-gen-private-key

COPY ./node.manifest.template .

RUN gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu node.manifest.template node.manifest \
    && gramine-sgx-sign --key enclaive-key.pem --manifest node.manifest --output node.manifest.sgx \
    && gramine-sgx-get-token --output node.token --sig node.sig

VOLUME /data/

EXPOSE 3000

ENTRYPOINT [ "/usr/local/bin/gramine-sgx", "node" ]