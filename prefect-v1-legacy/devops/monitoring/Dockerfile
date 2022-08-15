FROM python:3-alpine

WORKDIR /app

COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

RUN echo 'nobody:x:65534:65534:nobody:/:' > /app/passwd && \
    echo 'nobody:x:65534:' > /app/group

COPY monitor.py /app/

USER nobody:nobody

CMD ["python","-u", "/app/monitor.py"]
