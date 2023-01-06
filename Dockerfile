FROM ubuntu:18.04 as Ubuntu

ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa sudo

RUN adduser --disabled-password --gecos '' developer && adduser developer sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER developer
WORKDIR /home/developer

RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

COPY lib /home/developer/app/lib
COPY assets /home/developer/app/assets
COPY web /home/developer/app/web
COPY pubspec.yaml /home/developer/app/pubspec.yaml

RUN sudo chown -R developer:developer /home/developer

WORKDIR /home/developer/app

RUN flutter channel stable
RUN flutter upgrade
RUN flutter build web

FROM nginx:alpine
EXPOSE 80
COPY --from=Ubuntu /home/developer/app/build/web /usr/share/nginx/html