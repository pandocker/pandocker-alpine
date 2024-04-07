ARG ubuntu_version="22.04"
ARG alpine_version="3.16.4"
ARG pandoc_version="edge-alpine"
ARG pandoc_variant="extra"
ARG nexe_version="4.0.0-beta.19"


FROM ubuntu:${ubuntu_version} AS ricty-getter
RUN apt update && apt -y install --no-install-recommends fonts-ricty-diminished

FROM alpine:${alpine_version} AS wget-curl

RUN apk update && apk --no-cache add -U make curl gcc libc-dev libc6-compat

ENV PLANTUML_VERSION 1.2023.10
ENV PLANTUML_DOWNLOAD_URL https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar
RUN curl -fsSL "${PLANTUML_DOWNLOAD_URL}" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

FROM alpine:edge as csv
ARG lua_version="5.3"
RUN apk add --no-cache \
    make git \
    lua${lua_version}-dev \
    lua${lua_version}-lyaml lua${lua_version}-cjson \
    lua-penlight \
    luarocks${lua_version}
RUN git clone https://github.com/geoffleyland/lua-csv.git && cd lua-csv && \
    luarocks-${lua_version} make rockspecs/csv-1-1.rockspec

FROM lansible/nexe:${nexe_version} as wavedrom
WORKDIR /root
RUN apk add --update --no-cache \
    make \
    g++ \
    jpeg-dev \
    cairo-dev \
    giflib-dev \
    pango-dev \
    python3 \
    npm

RUN npm i canvas --build-from-source && \
    npm i https://github.com/K4zuki/cli.git && \
    nexe --build -i ./node_modules/wavedrom-cli/wavedrom-cli.js -o wavedrom-cli

FROM pandoc/${pandoc_variant}:${pandoc_version} as pandoc
WORKDIR /root

COPY src/BXptool/ /opt/texlive/texdir/texmf-dist/tex/latex/BXptool/
COPY src/pandoc_misc/ /tmp/

COPY --from=wget-curl /etc/apk/repositories /etc/apk/repositories
COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
COPY --from=wavedrom /root/wavedrom-cli /usr/local/bin/
COPY --from=csv /usr/local/share/lua/${lua_version} /usr/local/share/lua/${lua_version}

ARG tlmgr="false"
ARG texlive="2022"
ARG pip_opt=""

RUN mkdir -p "~/.config/pip"
ADD pip.conf ~/.config/pip/

RUN apk add --no-cache \
    make \
    lua${lua_version}-dev \
    lua${lua_version}-lyaml lua${lua_version}-cjson \
    lua-penlight \
    luarocks${lua_version}

RUN apk --no-cache add -U make openssl openjdk8 graphviz bash git

RUN apk --no-cache add -U python3 py3-pip py3-pillow py3-reportlab py3-lxml py3-lupa py3-setuptools_scm \
    py3-six py3-yaml py3-numpy

RUN apk add openjdk8-jre fontconfig ttf-dejavu font-noto-cjk font-noto-cjk-extra readline readline-dev && plantuml -version
RUN if [ ${tlmgr} = "true" ]; then \
        tlmgr option repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${texlive}/tlnet-final/ ; \
    else \
        echo "do not run update-tlmgr-latest.sh" && \
        tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet ; \
    fi

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

RUN pip3 install ${pip_opt} pandoc-imagine svgutils

RUN pip3 install ${pip_opt} pandocker-lua-filters docx-coreprop-writer

RUN pip3 install ${pip_opt} /tmp/pandoc_misc

RUN apk -vv info | sort

WORKDIR /workdir

VOLUME ["/workdir"]

ENV TZ JST-9
ENTRYPOINT [""]
CMD ["bash"]
