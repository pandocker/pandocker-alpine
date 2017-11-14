# Copyright (c) 2016 Kaito Udagawa
# Copyright (c) 2016-2017 3846masa
# Released under the MIT license
# https://opensource.org/licenses/MIT

FROM frolvlad/alpine-glibc

MAINTAINER 3846masa

ENV BUILD_DEPS \
    alpine-sdk \
    coreutils \
    ghc \
    gmp \
    libffi \
    linux-headers \
    musl-dev \
    wget \
    zlib-dev
ENV PERSISTENT_DEPS \
    graphviz \
    openjdk8 \
    python \
    py2-pip \
    sed \
    ttf-droid \
    ttf-droid-nonlatin
ENV EDGE_DEPS cabal

ENV PLANTUML_VERSION 1.2017.18
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download

ENV PANDOC_VERSION 2.0.1.1
ENV PANDOC_DOWNLOAD_URL https://hackage.haskell.org/package/pandoc-$PANDOC_VERSION/pandoc-$PANDOC_VERSION.tar.gz
ENV PANDOC_ROOT /usr/local/pandoc

ENV PATH $PATH:$PANDOC_ROOT/bin
ENV PATH /usr/local/texlive/2017/bin/x86_64-linux:$PATH

WORKDIR /pandoc-build
RUN apk --no-cache add perl wget xz tar fontconfig-dev && \
    mkdir /tmp/install-tl-unx && \
    wget -qO- ftp://tug.org/texlive/historic/2017/install-tl-unx.tar.gz | \
    tar -xz -C /tmp/install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "selected_scheme scheme-basic" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/install-tl-unx/texlive.profile && \
    /tmp/install-tl-unx/install-tl \
      --profile=/tmp/install-tl-unx/texlive.profile && \
    tlmgr install \
      collection-basic collection-latex \
      collection-latexrecommended collection-latexextra \
      collection-fontsrecommended collection-langjapanese latexmk && \
    ( tlmgr install xetex || exit 0 ) && \
    rm -fr /tmp/install-tl-unx && \
    wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip && \
    unzip v0.4.zip && \
    cp BXptool-0.4/bx*.{sty,def} /usr/share/texlive/texmf-dist/tex/latex/BXptool/ && \
    mktexlsr && \
    tlmgr install oberdiek && \
    wget -c https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip && \
        unzip -e 1.050R-it.zip && cp source-code-pro-2.030R-ro-1.050R-it/TTF/SourceCodePro-*.ttf /usr/local/share/fonts/ && \
    wget -c https://github.com/adobe-fonts/source-sans-pro/archive/2.020R-ro/1.075R-it.zip && \
        unzip -e 1.075R-it.zip && cp source-sans-pro-2.020R-ro-1.075R-it/TTF/SourceSansPro-*.ttf /usr/local/share/fonts/ && \
    wget -c https://github.com/mzyy94/RictyDiminished-for-Powerline/archive/3.2.4-powerline-early-2016.zip && \
        unzip -e 3.2.4-powerline-early-2016.zip && \
        cp RictyDiminished-for-Powerline-3.2.4-powerline-early-2016/RictyDiminished-*.ttf /usr/local/share/fonts/ && \
    rm 1.50R-it.zip 1.075R-it.zip 3.2.4-powerline-early-2016.zip && \
    apk --no-cache del xz tar perl && \
    apk --no-cache add bash && \
    # Create Pandoc build space
    mkdir -p /pandoc-build && \
    # Install/Build Packages
    apk upgrade --update && \
    apk add --no-cache --virtual .build-deps $BUILD_DEPS && \
    apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS && \
    curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
        echo "java -jar /usr/local/plantuml.jar \"$@\"" >> /usr/local/bin/plantuml && \
        chmod +x /usr/local/bin/plantuml && \
    wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.0.0-beta3/linux-ghc8-pandoc-2-0.tar.gz && \
        tar zxf linux-ghc8-pandoc-2-0.tar.gz && \
        mv pandoc-crossref /usr/local/bin/ && \
        rm linux*.gz && \
    apk add --no-cache --virtual .edge-deps $EDGE_DEPS -X http://dl-cdn.alpinelinux.org/alpine/edge/community && \
    curl -fsSL "$PANDOC_DOWNLOAD_URL" | tar -xzf - && \
        ( cd pandoc-$PANDOC_VERSION && cabal update && cabal install --only-dependencies && \
        cabal configure --prefix=$PANDOC_ROOT && \
        cabal build && \
        cabal copy && \
        cd .. ) && \
    rm -Rf pandoc-$PANDOC_VERSION/ && \
    rm -Rf /root/.cabal/ /root/.ghc/ && \
    rmdir /pandoc-build && \
    set -x && \
    apk del .build-deps .edge-deps

RUN mkdir /workdir

WORKDIR /workdir

VOLUME ["/workdir"]

CMD ["bash"]
