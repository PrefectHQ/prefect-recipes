from prometheus_client import start_http_server, Gauge
import time
import os
import logging
import sys
import httpx


# Project Variables
stateSubmitted = Gauge("state_submitted", "Current count of batch jobs in submitted state")
statePending = Gauge("state_pending", "Current count of batch jobs in pending state")
stateRunnable = Gauge("state_runnable", "Current count of batch jobs in runnable state")
stateStarting = Gauge("state_starting", "Current count of batch jobs in starting state")
stateRunning = Gauge("state_running", "Current count of batch jobs in running state")
stateSucceeded = Gauge("state_succeeded", "Current count of batch jobs in succeeded state")
stateFailed = Gauge("state_failed", "Current count of batch jobs in failed state")
allStates = ['SUBMITTED', 'PENDING', 'RUNNABLE', 'STARTING', 'RUNNING', 'SUCCEEDED', 'FAILED']

def query_batch_table():
    try:
        r = httpx.get(LAMBDA_URL)
        response = r.json()
        print (response)
        for state in allStates:
            if state not in response:
                response.update({state: 0})

    except Exception as e:
        logging.warning(repr(e))
    print (response)
    stateSubmitted.set(response['SUBMITTED'])
    statePending.set(response['PENDING'])
    stateRunnable.set(response['RUNNABLE'])
    stateStarting.set(response['STARTING'])
    stateRunning.set(response['RUNNING'])
    stateSucceeded.set(response['SUCCEEDED'])
    stateFailed.set(response['FAILED'])


if __name__ == "__main__":

    LAMBDA_URL = os.getenv('LAMBDA_URL', "")
    POLLING_INTERVAL = int(os.environ.get("POLLING_INTERVAL", 300))
    EXPORT_PORT = int(os.environ.get("EXPORT_PORT", 8000))
    logFormat = "%(asctime)s - %(message)s"
    logging.basicConfig(format=logFormat, stream=sys.stderr, level=logging.INFO)
    logger = logging.getLogger("prefect")
    # Start up the server to expose the metrics.
    start_http_server(EXPORT_PORT)

    # Core loop ; retrieve metrics then wait to poll again.
    while True:
        tic_main = time.time()
        logger.info("Getting table metrics.")
        query_batch_table()
        if LAMBDA_URL != "":
            query_batch_table()
        else:
            print (f"{LAMBDA_URL = }")
        toc_main = time.time()
        logger.info(f"Time Elapsed - {toc_main - tic_main}")
        logger.info(f"Sleeping for {POLLING_INTERVAL}.")
        time.sleep(POLLING_INTERVAL)
