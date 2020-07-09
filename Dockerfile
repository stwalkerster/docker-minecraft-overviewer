FROM ubuntu:bionic AS build
RUN apt-get update
RUN apt-get install -q -y build-essential python3-dev python3-numpy python3-pil git wget
RUN mkdir /opt/overviewer
WORKDIR /opt/overviewer
RUN git clone git://github.com/overviewer/Minecraft-Overviewer.git .
RUN python3 setup.py build
RUN wget https://overviewer.org/textures/1.15.2 -O 1.15.2.jar

FROM ubuntu:bionic
LABEL Maintainer="Simon Walker <simon@stwalkerster.co.uk>"
RUN useradd -d /opt/overviewer overviewer \
    && mkdir -p /opt/overviewer/.minecraft/versions/1.15.2 \
    && apt-get update \
    && apt-get install --no-install-recommends -q -y python3 python3-numpy python3-pil \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER overviewer
WORKDIR /opt/overviewer
COPY --from=build /opt/overviewer/overviewer.py .
COPY --from=build /opt/overviewer/overviewer_core /opt/overviewer/overviewer_core/
COPY --from=build /opt/overviewer/1.15.2.jar /opt/overviewer/.minecraft/versions/1.15.2/1.15.2.jar

ENV BUILD_WORLD_UNIX_NAME=minecraft \
    BUILD_WORLD_NAME=Minecraft \
    BUILD_WORLD_PATH=/world \
    PYTHONPATH=/opt/overviewer:/opt/overviewer/overviewer_core:/config

VOLUME /map /world /config
ENTRYPOINT ["nice", "./overviewer.py"]
