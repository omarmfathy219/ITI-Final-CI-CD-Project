FROM python:3.8

RUN mkdir /myApp
WORKDIR /myApp

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

ENV ENVIRONMENT=DEV
ENV HOST=localhost
ENV PORT=8080
ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV REDIS_DB=0

EXPOSE 8080

CMD ["python", "hello.py"]
