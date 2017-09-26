FROM python:3

ARG GO_PIPELINE_NAME=manual
ARG GO_PIPELINE_LABEL=manual
ARG GO_PIPELINE_COUNTER=manual
ARG GO_REVISION_GIT=manual
ARG GO_STAGE_COUNTER=manual
LABEL description="uBirch BigchainDB Service container"
LABEL GO_PIPELINE_NAME=${GO_PIPELINE_NAME}
ENV GO_PIPELINE_NAME=${GO_PIPELINE_NAME}
LABEL GO_PIPELINE_LABEL=${GO_PIPELINE_LABEL}
ENV GO_PIPELINE_LABEL=${GO_PIPELINE_LABEL}
LABEL GO_REVISION_GIT=${GO_REVISION_GIT}
ENV GO_REVISION_GIT=${GO_REVISION_GIT}
LABEL GO_PIPELINE_COUNTER=${GO_PIPELINE_COUNTER}
ENV GO_PIPELINE_COUNTER=${GO_PIPELINE_COUNTER}
LABEL GO_STAGE_COUNTER=${GO_STAGE_COUNTER}
ENV GO_STAGE_COUNTER=${GO_STAGE_COUNTER}

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

ENV IPDB_APP_ID=$IPDB_APP_ID
ENV IPDB_APP_KEY=$IPDB_APP_KEY
###ENV BIG_CHAIN_DB_HOST=$BIG_CHAIN_DB_HOST
ENV BIG_CHAIN_DB_HOST=$MONGO_BIGCHAIN_HOST_1

ENV SQS_CHAIN_IN=$SQS_UBIRCH_BIGCHAIN_DB_IN
ENV SQS_CHAIN_TX=$SQS_UBIRCH_BIGCHAIN_DB_TX
ENV SQS_REGION=$AWS_REGION

COPY src/bigChainDbStore.py ./

### CMD [ "python", "./ipdbTransmitter.py" ]
CMD [ "python", "./bigChainDbStore.py" ]
