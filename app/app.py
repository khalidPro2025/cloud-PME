from fastapi import FastAPI

app = FastAPI(title="Cloud PME - FastAPI")

@app.get("/")
def home():
    return {"message": "Application Cloud Open Source pour PME (FastAPI)"}
