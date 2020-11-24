FROM sulantha/ants:v2.3.4 AS ants_build
FROM sulantha/c3d:1.0.0 AS c3d_build

FROM python:buster as release
USER root

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
           git \
           bash \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/* \
     && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
     && dpkg-reconfigure --frontend=noninteractive locales \
     && update-locale LANG="en_US.UTF-8"

COPY --from=ants_build /opt/ants /opt/ants
COPY --from=c3d_build /opt/convert3d /opt/convert3d

ENV ANTSPATH="/opt/ants" \
    PATH="/opt/ants/bin:$PATH"
ENV C3DPATH="/opt/convert3d" \
    PATH="/opt/convert3d/bin:$PATH"

RUN pip install nipype

RUN echo $(/opt/ants/bin/antsRegistration --version)
RUN echo $(/opt/convert3d/bin/c3d -version)

ENV SHELL=/bin/bash
CMD ["/bin/bash"]
