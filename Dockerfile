FROM ubuntu:22.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  curl \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(lsb_release -sc) main" \
  | tee /etc/apt/sources.list.d/gramine.list

RUN curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -sc) main" \
  | tee /etc/apt/sources.list.d/intel-sgx.list

RUN apt-get install -y --no-install-recommends \
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