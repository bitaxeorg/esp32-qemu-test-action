FROM espressif/idf:v6.0.2

ARG DEBIAN_FRONTEND=nointeractive

# QEMU
ENV ESP_QEMU_RELEASE=esp-develop-9.2.2-20260417
ENV ESP_QEMU_DIST=qemu-xtensa-softmmu-esp_develop_9.2.2_20260417-x86_64-linux-gnu.tar.xz
ENV ESP_QEMU_URL=https://github.com/espressif/qemu/releases/download/${ESP_QEMU_RELEASE}/${ESP_QEMU_DIST}

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN wget --no-verbose ${ESP_QEMU_URL} \
  && tar -xf ${ESP_QEMU_DIST} -C /opt \
  && rm ${ESP_QEMU_DIST}

ENV UNITY_REL=v2.7.0
ENV UNITY_DIST=${UNITY_REL}.tar.gz
ENV UNITY_URL=https://github.com/ThrowTheSwitch/Unity/archive/refs/tags/${UNITY_DIST}

RUN wget --no-verbose ${UNITY_URL} \
  && tar -xf ${UNITY_DIST} -C /opt \
  && rm ${UNITY_DIST}

ENV PATH=/opt/qemu/bin:${PATH}

RUN echo $($IDF_PATH/tools/idf_tools.py export) >> $HOME/.bashrc

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
