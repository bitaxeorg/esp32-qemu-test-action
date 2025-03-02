FROM espressif/idf:v5.4

ARG DEBIAN_FRONTEND=nointeractive

# QEMU
ENV ESP_QEMU_RELEASE=esp-develop-9.2.2-20250228
ENV ESP_QEMU_DIST=qemu-xtensa-softmmu-esp_develop_9.2.2_20250228-x86_64-linux-gnu.tar.xz
ENV ESP_QEMU_URL=https://github.com/espressif/qemu/releases/download/${ESP_QEMU_RELEASE}/${ESP_QEMU_DIST}

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV IDF_PYTHON_export_PATH=/opt/esp/python_export/idf5.3_py3.10_export

RUN wget --no-verbose ${ESP_QEMU_URL} \
  && tar -xf ${ESP_QEMU_DIST} -C /opt \
  && rm ${ESP_QEMU_DIST}

ENV UNITY_REL=v2.6.0
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
