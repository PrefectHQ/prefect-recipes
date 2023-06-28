FROM prefecthq/prefect:2-python3.9

COPY requirements.txt /opt/prefect/flows/
COPY retrieve_secrets.py /opt/prefect/

RUN pip install -r /opt/prefect/flows/requirements.txt
