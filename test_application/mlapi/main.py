import logging
import os
from tokenize import Floatnumber
from unicodedata import decimal, numeric

from fastapi import FastAPI, Request, Response
from fastapi_redis_cache import FastApiRedisCache, cache_one_minute
from pydantic import BaseModel, Extra
from transformers import pipeline, AutoModelForSequenceClassification, AutoTokenizer


model_path = "./distilbert-base-uncased-finetuned-sst2"
model = AutoModelForSequenceClassification.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)
classifier = pipeline(
    task="text-classification",
    model=model,
    tokenizer=tokenizer,
    device=-1,
    return_all_scores=True,
)

logger = logging.getLogger(__name__)
LOCAL_REDIS_URL = "redis://redis:6379/0"
app = FastAPI()


@app.on_event("startup")
def startup():
    redis_host = os.environ.get("REDIS_SERVER","redis")
    redis_url  = "redis://"+ redis_host + ":6379/0"
    redis_cache = FastApiRedisCache()
    redis_cache.init(
        host_url=redis_url,
        prefix="mlapi-cache",
        response_header="X-MLAPI-Cache",
        ignore_arg_types=[Request, Response],
    )

class SentimentRequest(BaseModel,extra=Extra.forbid):
    text: list[str]

class Sentiment(BaseModel,extra=Extra.forbid):
    label: str
    score: float

class SentimentResponse(BaseModel,extra=Extra.forbid):
    predictions: list[list[Sentiment]]
    #predictions: list[Sentiment]

class BOZO(BaseModel):
    dealio: int

@app.post("/predict", response_model=SentimentResponse)
@cache_one_minute()
def predict(sentiments: SentimentRequest):
    return {"predictions": classifier(sentiments.text)}


@app.get("/health")
async def health():
    return {"status": "healthy"}
