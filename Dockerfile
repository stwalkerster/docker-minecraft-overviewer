FROM ubuntu:bionic AS build
ARG MinecraftVersion
RUN apt-get update
RUN apt-get install -q -y build-essential python3-dev python3-numpy python3-pil git wget
RUN mkdir /opt/overviewer
WORKDIR /opt/overviewer
COPY git/ .
RUN ls -l
RUN python3 setup.py build
RUN wget https://overviewer.org/textures/${MinecraftVersion} -O ${MinecraftVersion}.jar

FROM ubuntu:bionic
ARG MinecraftVersion
ARG TEAMCITY_PROJECT_NAME TEAMCITY_BUILDCONF_NAME BUILD_NUMBER BUILD_VCS_NUMBER_BuildPrerequisites_Docker BUILD_VCS_NUMBER_BuildPrerequisites_MinecraftOverviewer
LABEL Maintainer="Simon Walker <simon@stwalkerster.co.uk>"
LABEL TeamCityProject=${TEAMCITY_PROJECT_NAME}
LABEL TeamCityBuildConf=${TEAMCITY_BUILDCONF_NAME}
LABEL Build=${BUILD_NUMBER}
LABEL DockerfileGitRev=${BUILD_VCS_NUMBER_BuildPrerequisites_Docker}
LABEL OverviewerGitRev=${BUILD_VCS_NUMBER_BuildPrerequisites_Docker}
LABEL Minecraft=${MinecraftVersion}
RUN useradd -d /opt/overviewer overviewer \
    && mkdir -p /opt/overviewer/.minecraft/versions/${MinecraftVersion} \
    && apt-get update \
    && apt-get install --no-install-recommends -q -y python3 python3-numpy python3-pil \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER overviewer
WORKDIR /opt/overviewer
COPY --from=build /opt/overviewer/overviewer.py .
COPY --from=build /opt/overviewer/overviewer_core /opt/overviewer/overviewer_core/
COPY --from=build /opt/overviewer/${MinecraftVersion}.jar /opt/overviewer/.minecraft/versions/${MinecraftVersion}/${MinecraftVersion}.jar

ENV BUILD_WORLD_UNIX_NAME=minecraft \
    BUILD_WORLD_NAME=Minecraft \
    BUILD_WORLD_PATH=/world \
    PYTHONPATH=/opt/overviewer:/opt/overviewer/overviewer_core:/config

VOLUME /map /world /config
ENTRYPOINT ["nice", "./overviewer.py"]
