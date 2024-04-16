FROM swipl:latest
COPY . /app
EXPOSE 8000
CMD swipl /app/web.pl