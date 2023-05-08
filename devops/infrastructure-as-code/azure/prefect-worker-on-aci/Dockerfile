FROM prefecthq/prefect:2-python3.9

COPY flow.py /opt/prefect/flows/
COPY requirements.txt /opt/prefect/flows/

RUN pip install -r /opt/prefect/flows/requirements.txt
