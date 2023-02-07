ARG ubuntu_version="22.04"
ARG alpine_version="3.16.1"
ARG pandoc_version="2.19"
ARG nexe_version="4.0.0-rc.2"

FROM ubuntu:${ubuntu_version} AS ricty-getter
RUN apt update && apt -y install --no-install-recommends fonts-ricty-diminished

FROM alpine:${alpine_version} AS wget-curl

RUN apk update && apk --no-cache add -U make curl gcc libc-dev libc6-compat

ENV PLANTUML_VERSION 1.2022.6
ENV PLANTUML_DOWNLOAD_URL https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar
RUN curl -fsSL "${PLANTUML_DOWNLOAD_URL}" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

FROM lansible/nexe:${nexe_version} as wavedrom
WORKDIR /root
RUN apk add --update --no-cache \
    make \
    g++ \
    jpeg-dev \
    cairo-dev \
    giflib-dev \
    pango-dev \
    python3

RUN npm i canvas --build-from-source && \
    npm i https://github.com/K4zuki/cli.git && \
    nexe --build -i ./node_modules/wavedrom-cli/wavedrom-cli.js -o wavedrom-cli

FROM pandoc/latex:${pandoc_version} as pandoc

COPY src/BXptool-0.4/ /opt/texlive/texdir/texmf-dist/tex/latex/BXptool/

COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
COPY --from=wavedrom /root/wavedrom-cli /usr/local/bin/

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories && \
    apk update

RUN apk add --no-cache \
    make \
    lua5.3-dev \
    lua5.3-lyaml lua5.3-cjson \
    lua-penlight luarocks5.3

RUN apk --no-cache add -U make openssl openjdk8 graphviz bash git

RUN apk --no-cache add -U python3 py3-pip py3-pillow py3-reportlab py3-lxml py3-lupa py3-setuptools_scm \
    py3-six py3-yaml py3-numpy

RUN git clone https://github.com/geoffleyland/lua-csv.git && cd lua-csv && luarocks-5.3 make rockspecs/csv-1-1.rockspec

RUN apk add openjdk8-jre fontconfig ttf-dejavu font-noto-cjk font-noto-cjk-extra && plantuml -version
RUN curl -L -O http://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh && bash update-tlmgr-latest.sh
RUN tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet
RUN tlmgr update --self && fc-cache -fv && tlmgr install \
    ascmac \
    background \
    bxjscls \
    ctex \
    environ \
    everypage \
    fancybox \
    ifoddpage \
    lastpage \
    mdframed \
    needspace \
    realscripts\
    tcolorbox \
    trimspaces \
    xhfill \
    xltxtra \
    zref \
    zxjafont \
    zxjatype && mktexlsr

RUN pip3 install pandoc-imagine svgutils

RUN pip3 install pandocker-lua-filters docx-coreprop-writer

RUN pip3 install git+https://github.com/k4zuki/pandoc_misc.git@2.16.2

RUN apk -vv info | sort

WORKDIR /workdir

VOLUME ["/workdir"]

ENV TZ JST-9
ENTRYPOINT [""]
CMD ["bash"]
