from fastapi import FastAPI

app = FastAPI(title="Cloud PME - FastAPI")
def home():
    return {"message": "Application Cloud Open Source pour PME (fastapi)"}

