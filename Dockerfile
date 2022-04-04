FROM alpine:latest

RUN echo "|--> Updating" \
    && apk update && apk upgrade \
    && apk --no-cache add musl-dev linux-headers g++ \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories \
    && echo "|--> Install basics pre-requisites" \
    && apk add --no-cache tini \
        curl ca-certificates python3 py3-numpy py3-numpy-f2py \
        freetype jpeg libpng libstdc++ libgomp graphviz font-noto \
    && echo "|--> Install Python basics" \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 --no-cache-dir install --upgrade pip setuptools wheel \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
    && ln -s locale.h /usr/include/xlocale.h \
    && echo "|--> Install build dependencies" \
    && apk add --no-cache --virtual=.build-deps \
        build-base linux-headers python3-dev git cmake jpeg-dev bash \
        libffi-dev gfortran openblas-dev py-numpy-dev freetype-dev libpng-dev \
    && echo "|--> Install Python packages" \
    && pip install -U --no-cache-dir pyyaml pymkl cffi scikit-learn \
        matplotlib ipywidgets notebook requests pillow pandas seaborn \
    && echo "|--> Cleaning" \
    && rm /usr/include/xlocale.h \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    && rm -rf /var/cache/apk/* \
    && find /usr/lib/python3.6 -name __pycache__ | xargs rm -r \
    && echo "|--> Configure Jupyter extension" \
    && jupyter nbextension enable --py widgetsnbextension \
    && mkdir -p ~/.ipython/profile_default/startup/ \
    && echo "import warnings" >> ~/.ipython/profile_default/startup/config.py \
    && echo "warnings.filterwarnings('ignore')" >> ~/.ipython/profile_default/startup/config.py \
    && echo "c.NotebookApp.token = u''" >> ~/.ipython/profile_default/startup/config.py \
    && echo "|--> Done!"
ENTRYPOINT ["/sbin/tini", "--"]

RUN echo "|--> Updating" \
    && echo "|--> Install PyTorch" \
    && git clone --recursive https://github.com/pytorch/pytorch \
    && cd pytorch && python setup.py install \
    && echo "|--> Install Torch Vision" \
    && git clone --recursive https://github.com/pytorch/vision \
    && cd vision && python setup.py install \
    && echo "|--> Cleaning" \
    && rm -rf /pytorch \
    && rm -rf /root/.cache \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps \
    && find /usr/lib/python3.6 -name __pycache__ | xargs rm -r \
    && rm -rf /root/.[acpw]*

RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install numpy pandas
RUN pip install torch torchvision


