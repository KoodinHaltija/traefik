
FROM python:2.7
RUN  pip install --verbose   Flask==0.12.1 uwsgi==2.0.17.1 logging redis

WORKDIR /app
COPY app.py /app
RUN mkdir -p tmp
RUN ls -la > tmp/flask.log


RUN ls -la 

CMD ["uwsgi","--http",":9090","--wsgi-file","/app/app.py","--callable","app","--stats","0.0.0.0:9191"]