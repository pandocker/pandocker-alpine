FROM alpine:3.9

MAINTAINER k4zuki

RUN apk --no-cache add -U make librsvg curl openssl gcc libc-dev libc6-compat openjdk8 graphviz && \
    mkdir -p /workdir && \
    mkdir -p /usr/share/texlive/texmf-dist/tex/latex/BXptool/ && \
    mkdir -p /usr/local/share/fonts
COPY src/sourcecodepro/*.ttf /usr/share/fonts/
COPY src/sourcesanspro/*.ttf /usr/share/fonts/
COPY src/BXptool-0.4/bx*.sty src/BXptool-0.4/bx*.def /usr/share/texlive/texmf-dist/tex/latex/BXptool/
COPY bin/pandoc-crossref-alpine /usr/local/bin/pandoc-crossref
RUN wget -c https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansJ.zip && \
      unzip SourceHanSansJ.zip && cp SourceHanSansJ/SourceHanSans-*.otf /usr/share/fonts/

WORKDIR /workdir

RUN apk --no-cache add -U python3 py3-pillow libxml2-dev libxslt-dev python3-dev \
      musl-dev bash git

# RUN set -ex \
#   && apk add --no-cache --virtual .build-deps ca-certificates openssl \
#   && curl -Ls "https://github.com/dustinblackman/phantomized/releases/download/2.1.1a/dockerized-phantomjs.tar.gz" | tar xz -C / \
#   && npm install -g phantomjs-prebuilt \
#   && apk del .build-deps
#
# RUN npm install -g wavedrom-cli \
#       fs-extra yargs onml bit-field

# dependencies for texlive
RUN apk --no-cache add -U \
    poppler harfbuzz-icu py3-libxml2 && \
      pip3 install -U \
      pantable csv2table \
      six pandoc-imagine \
      svgutils \
      pyyaml bitfieldpy pandoc-pandocker-filters \
      git+https://github.com/pandocker/removalnotes.git \
      git+https://github.com/pandocker/tex-landscape.git \
      git+https://github.com/pandocker/pandoc-blockdiag-filter.git \
      git+https://github.com/pandocker/pandoc-docx-pagebreak-py.git \
      git+https://github.com/pandocker/pandoc-docx-utils-py.git \
      git+https://github.com/pandocker/pandoc-svgbob-filter.git \
      git+https://github.com/pandocker/pandocker-lua-filters.git
# zziplib (found in edge/community repository) is a dependency to texlive-luatex
# ghc & cabal also
RUN pip3 install git+https://github.com/k4zuki/pandoc_misc.git@lua-filter \
      git+https://github.com/k4zuki/docx-core-property-writer.git

RUN apk --no-cache add -U zziplib texlive-xetex && \
    ln -s /usr/bin/mktexlsr /usr/bin/mktexlsr.pl && \
    mktexlsr && fc-cache -fv

RUN wget -c https://github.com/logological/gpp/releases/download/2.25/gpp-2.25.tar.bz2 && \
    tar jxf gpp-2.25.tar.bz2 && cd gpp-2.25 && ./configure && make && cp src/gpp /usr/bin/

RUN apk add openjdk8-jre fontconfig ttf-dejavu
ENV PLANTUML_VERSION 1.2017.18
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download
RUN curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml && plantuml -v

ENV PANDOC_VERSION 2.1.3
ENV PANDOC_ARCHIVE pandoc-$PANDOC_VERSION
ENV PANDOC_URL https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/
RUN wget --no-check-certificate $PANDOC_URL/$PANDOC_ARCHIVE-linux.tar.gz && \
    tar zxf $PANDOC_ARCHIVE-linux.tar.gz && cp $PANDOC_ARCHIVE/bin/* /usr/local/bin/

# ENV CROSSREF_VERSION v0.3.0.0
# ENV CROSSREF_ARCHIVE linux-ghc8-pandoc-2-0.tar.gz
# ENV CROSSREF_URL https://github.com/lierdakil/pandoc-crossref/releases/download/$CROSSREF_VERSION
# # RUN cabal update && cabal install pandoc-cross
# RUN wget --no-check-certificate $CROSSREF_URL/$CROSSREF_ARCHIVE && \
#     tar zxf $CROSSREF_ARCHIVE && \
#     mv pandoc-crossref /usr/local/bin/

RUN wget -c https://github.com/tcnksm/ghr/releases/download/v0.5.4/ghr_v0.5.4_linux_amd64.zip && \
    unzip ghr_v0.5.4_linux_amd64.zip && \
    mv ghr /usr/local/bin/ && \
    rm ghr_v0.5.4_linux_amd64.zip

WORKDIR /var
ENV PANDOC_MISC_VERSION 0.0.21
RUN git clone --recursive --depth=1 https://github.com/K4zuki/pandoc_misc.git
RUN apk del *-doc

WORKDIR /workdir

VOLUME ["/workdir"]

ENV TZ JST-9
CMD ["bash"]
