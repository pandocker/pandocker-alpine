FROM ubuntu:20.04 AS ricty-getter
RUN apt update && apt -y install --no-install-recommends fonts-ricty-diminished

FROM alpine:3.12 AS wget-curl

RUN apk update && apk --no-cache add -U make curl gcc libc-dev libc6-compat

ENV PLANTUML_VERSION 1.2020.15
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download
RUN curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

RUN wget -c https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansJ.zip && \
      unzip SourceHanSansJ.zip

FROM pandoc/latex:2.10 as pandoc
FROM alpine:3.12 AS base

COPY src/BXptool-0.4/ /opt/texlive/texdir/texmf-dist/tex/latex/BXptool/
#COPY src/sourcecodepro/*.ttf /usr/share/fonts/
COPY src/sourcesanspro/*.ttf /usr/share/fonts/
COPY src/noto-jp/*.otf /usr/share/fonts/

COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
COPY --from=wget-curl /SourceHanSansJ/ /usr/share/fonts/SourceHanSansJ/
COPY --from=ricty-getter /usr/share/fonts/truetype/ricty-diminished/ /usr/share/fonts/truetype/ricty-diminished/
COPY --from=pandoc / /
ENV PATH /opt/texlive/texdir/bin/x86_64-linuxmusl:$PATH

RUN apk add --no-cache \
    make \
    lua5.3-dev \
    lua5.3-lyaml lua5.3-cjson \
    lua-penlight luarocks5.3

RUN apk --no-cache add -U make openssl openjdk8 graphviz bash git font-source-code-pro-nerd

RUN apk --no-cache add -U python3 py3-pip py3-pillow py3-reportlab py3-lxml py3-lupa py3-setuptools_scm \
    py3-six py3-yaml

RUN git clone https://github.com/geoffleyland/lua-csv.git && cd lua-csv && luarocks-5.3 make rockspecs/csv-1-1.rockspec

RUN apk add openjdk8-jre fontconfig ttf-dejavu && plantuml -version
RUN tlmgr update --self && fc-cache -fv && tlmgr install \
    ascmac \
    bxjscls \
    environ \
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

RUN pip3 install pandoc-pandocker-filters \
    git+https://github.com/pandocker/pandoc-blockdiag-filter.git \
    git+https://github.com/pandocker/pandoc-docx-utils-py.git \
    git+https://github.com/pandocker/pandoc-svgbob-filter.git \
    git+https://github.com/pandocker/pandocker-lua-filters.git

RUN pip3 install git+https://github.com/k4zuki/pandoc_misc.git@2.8 \
      git+https://github.com/k4zuki/docx-core-property-writer.git

RUN apk -vv info | sort

WORKDIR /workdir

VOLUME ["/workdir"]

ENV TZ JST-9
ENTRYPOINT [""]
CMD ["bash"]
