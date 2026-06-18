# Alertmanager to SMSEagle gateway

build:
```
docker build -t smsbridge .
```

run (see `env` for example env vars):
```
docker run -p 9095:9095 --env-file env smsbridge
```

tests:
```
./tests/send-alert.sh
```
