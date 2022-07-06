FROM python:3 as builder

WORKDIR /app

COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

COPY monitor.py /app/

RUN echo 'nobody:x:65534:65534:nobody:/:' > /app/passwd && \
    echo 'nobody:x:65534:' > /app/group

#RUN apk --no-cache add ca-certificates

FROM scratch

WORKDIR /app

COPY --from=builder /app/monitor.py /app/
COPY --from=builder /app/group /app/passwd /etc/
#COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

USER nobody:nobody

CMD ["python", "/app/monitor.py"]
#ENTRYPOINT [ "/app/monitor.py" ]
