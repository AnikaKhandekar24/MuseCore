from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles

from database import MusicDatabase
from models import FavoriteRequest, HistoryRequest, MoodPlaylistRequest, RecommendRequest, Song
from recommender import recommend_songs, mood_playlist


app = FastAPI(
    title="MuseCore API",
    description="A Python-powered recommendation backend for a SwiftUI personal music app.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

db = MusicDatabase()
STATIC_DIR = Path(__file__).with_name("static")

app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


@app.get("/")
def root() -> RedirectResponse:
    return RedirectResponse(url="/preview")


@app.get("/preview")
def preview() -> RedirectResponse:
    return RedirectResponse(url="/static/index.html")


@app.get("/songs", response_model=list[Song])
def get_songs() -> list[Song]:
    return db.all_songs()


@app.post("/recommend", response_model=list[Song])
def recommend(request: RecommendRequest) -> list[Song]:
    recent = request.recently_played or db.recently_played_ids()
    skipped = request.skipped_songs or db.skipped_ids()

    return recommend_songs(
        songs=db.all_songs(),
        mood=request.mood,
        energy_level=request.energy_level,
        time_of_day=request.time_of_day,
        recently_played=recent,
        skipped_songs=skipped,
        limit=request.limit,
    )


@app.post("/mood-playlist", response_model=list[Song])
def create_mood_playlist(request: MoodPlaylistRequest) -> list[Song]:
    return mood_playlist(
        songs=db.all_songs(),
        mood=request.mood,
        study_mode=request.study_mode,
        limit=request.limit,
    )


@app.get("/favorites", response_model=list[Song])
def get_favorites() -> list[Song]:
    return db.favorite_songs()


@app.post("/favorites", response_model=Song)
def update_favorite(request: FavoriteRequest) -> Song:
    song = db.set_favorite(request.song_id, request.favorite)
    if song is None:
        raise HTTPException(status_code=404, detail="Song not found")
    return song


@app.get("/history", response_model=list[Song])
def get_history() -> list[Song]:
    songs = []
    seen_ids = set()
    for item in db.history:
        song_id = item["song_id"]
        if song_id in seen_ids:
            continue
        song = db.get_song(song_id)
        if song:
            songs.append(song)
            seen_ids.add(song_id)
    return songs


@app.post("/history", response_model=Song)
def add_history(request: HistoryRequest) -> Song:
    song = db.add_history(request.song_id, request.skipped)
    if song is None:
        raise HTTPException(status_code=404, detail="Song not found")
    return song


@app.get("/insights")
def get_insights() -> dict:
    return db.insights()
