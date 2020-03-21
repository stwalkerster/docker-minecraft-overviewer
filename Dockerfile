FROM ubuntu:bionic AS build
RUN apt-get update
RUN apt-get install -q -y build-essential python3-dev python3-numpy python3-pil git
RUN mkdir /opt/overviewer
WORKDIR /opt/overviewer
RUN git clone git://github.com/overviewer/Minecraft-Overviewer.git .
RUN python3 setup.py build
RUN apt-get clean

FROM ubuntu:bionic
ENV CONFIG=
LABEL Maintainer="Simon Walker <simon@stwalkerster.co.uk>"
RUN mkdir /opt/overviewer && \
    apt-get update && \
    apt-get install --no-install-recommends -q -y python3 python3-numpy python3-pil && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd overviewer
USER overviewer
WORKDIR /opt/overviewer
COPY --from=build /opt/overviewer/overviewer.py .
COPY --from=build /opt/overviewer/overviewer_core /opt/overviewer/overviewer_core/
VOLUME /map /world
ENTRYPOINT ./overviewer.py --config=$CONFIG
