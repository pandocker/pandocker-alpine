FROM alpine:edge AS noto-cjk
RUN apk update && apk add font-noto-cjk font-noto-cjk-extra font-noto

FROM alpine:3.10 AS wget-curl

RUN apk update && apk --no-cache add -U make curl gcc libc-dev libc6-compat
RUN wget -c https://github.com/logological/gpp/releases/download/2.25/gpp-2.25.tar.bz2 && \
    tar jxf gpp-2.25.tar.bz2 && cd gpp-2.25 && ./configure && make && cp src/gpp /usr/bin/

ENV PLANTUML_VERSION 1.2019.7
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download
RUN curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

#RUN wget -c https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansJ.zip && \
#      unzip SourceHanSansJ.zip

FROM alpine:3.10 AS base

COPY src/BXptool-0.4/ /opt/texlive/texdir/texmf-dist/tex/latex/BXptool/
COPY bin/pandoc-crossref-alpine /usr/local/bin/pandoc-crossref

COPY --from=wget-curl /usr/bin/gpp /usr/bin/gpp
COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
#COPY --from=wget-curl /SourceHanSansJ/ /usr/share/fonts/
COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
COPY --from=noto-cjk /usr/share/fonts/noto/ /usr/share/fonts/noto/
COPY --from=pandoc/latex:2.7.3 / /
ENV PATH /opt/texlive/texdir/bin/x86_64-linuxmusl:$PATH

RUN apk add --no-cache \
    gmp make \
    libffi \
    lua5.3 lua5.3-dev \
    lua5.3-lpeg \
    lua5.3-lyaml lua5.3-cjson \
    lua-penlight luarocks5.3 && \
    luarocks-5.3 install lua-csv

RUN apk --no-cache add -U make librsvg curl openssl openjdk8 graphviz bash git
RUN apk --no-cache add -U python3 py3-pillow py3-reportlab py3-lxml py3-lupa py3-setuptools_scm

RUN apk add openjdk8-jre fontconfig ttf-dejavu && tlmgr update --self && fc-cache -fv && plantuml -version
RUN tlmgr install \
    ascmac \
    environ \
    ifoddpage \
    lastpage \
    mdframed \
    needspace \
    tcolorbox \
    trimspaces \
    xhfill

RUN pip3 install pantable csv2table six pandoc-imagine svgutils pyyaml

RUN pip3 install pandoc-pandocker-filters \
#    git+https://github.com/pandocker/removalnotes.git \
#    git+https://github.com/pandocker/tex-landscape.git \
    git+https://github.com/pandocker/pandoc-blockdiag-filter.git \
#    git+https://github.com/pandocker/pandoc-docx-pagebreak-py.git \
    git+https://github.com/pandocker/pandoc-docx-utils-py.git \
    git+https://github.com/pandocker/pandoc-svgbob-filter.git \
    git+https://github.com/pandocker/pandocker-lua-filters.git

RUN pip3 install git+https://github.com/k4zuki/pandoc_misc.git@lua-filter \
      git+https://github.com/k4zuki/docx-core-property-writer.git

WORKDIR /workdir

VOLUME ["/workdir"]

ENV TZ JST-9
CMD ["bash"]
