FROM dart:3.2

WORKDIR /app

ADD . /app/
RUN dart pub get
RUN dart pub global activate conduit
EXPOSE 6100

ENTRYPOINT [ "dart","pub","run","conduit:conduit","serve","--port","6100" ]