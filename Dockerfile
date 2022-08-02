ARG ubuntu_version="20.04"
ARG alpine_version="3.12.9"
ARG pandoc_version="2.18"
ARG nexe_version="4.0.0-beta.19"

FROM ubuntu:${ubuntu_version} AS ricty-getter
RUN apt update && apt -y install --no-install-recommends fonts-ricty-diminished

FROM alpine:${alpine_version} AS wget-curl

RUN apk update && apk --no-cache add -U make curl gcc libc-dev libc6-compat

ENV PLANTUML_VERSION 1.2020.15
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download
RUN curl -fsSL "${PLANTUML_DOWNLOAD_URL}" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

RUN wget -c https://github.com/adobe-fonts/source-han-sans/releases/download/2.004R/SourceHanSansHWJ.zip && \
      mkdir SourceHanSansJ && \
      unzip SourceHanSansHWJ.zip -d SourceHanSansJ

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
    npm i wavedrom-cli && \
    nexe --build -i ./node_modules/wavedrom-cli/wavedrom-cli.js -o wavedrom-cli

FROM pandoc/latex:${pandoc_version} as pandoc

COPY src/BXptool-0.4/ /opt/texlive/texdir/texmf-dist/tex/latex/BXptool/
#COPY src/sourcecodepro/*.ttf /usr/share/fonts/
COPY src/sourcesanspro/*.ttf /usr/share/fonts/
COPY src/noto-jp/*.otf /usr/share/fonts/

COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
COPY --from=wget-curl /SourceHanSansJ/ /usr/share/fonts/SourceHanSansJ/
COPY --from=ricty-getter /usr/share/fonts/truetype/ricty-diminished/ /usr/share/fonts/truetype/ricty-diminished/
COPY --from=wavedrom /root/wavedrom-cli /usr/local/bin/

RUN apk add --no-cache \
    make \
    lua5.3-dev \
    lua5.3-lyaml lua5.3-cjson \
    lua-penlight luarocks5.3

RUN apk --no-cache add -U make openssl openjdk8 graphviz bash git

RUN apk --no-cache add -U python3 py3-pip py3-pillow py3-reportlab py3-lxml py3-lupa py3-setuptools_scm \
    py3-six py3-yaml py3-numpy

RUN git clone https://github.com/geoffleyland/lua-csv.git && cd lua-csv && luarocks-5.3 make rockspecs/csv-1-1.rockspec

RUN apk add openjdk8-jre fontconfig ttf-dejavu && plantuml -version
RUN tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet
RUN tlmgr update --self && fc-cache -fv && tlmgr install \
    ascmac \
    background \
    bxjscls \
    ctex \
    environ \
    everypage \
    haranoaji \
    haranoaji-extra \
    ifoddpage \
    lastpage \
    mdframed \
    needspace \
    tcolorbox \
    trimspaces \
    xhfill \
    zref \
    zxjafont \
    zxjatype && mktexlsr

RUN pip3 install pantable csv2table pandoc-imagine svgutils

RUN pip3 install pandoc-pandocker-filters pandocker-lua-filters \
    git+https://github.com/pandocker/pandoc-blockdiag-filter.git \
    git+https://github.com/pandocker/pandoc-docx-utils-py.git \
    git+https://github.com/pandocker/pandoc-svgbob-filter.git

RUN pip3 install git+https://github.com/k4zuki/pandoc_misc.git@2.16.2 \
      git+https://github.com/k4zuki/docx-core-property-writer.git

RUN apk -vv info | sort

WORKDIR /workdir

VOLUME ["/workdir"]

ENV TZ JST-9
ENTRYPOINT [""]
CMD ["bash"]
