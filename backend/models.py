from pydantic import BaseModel, Field


class Song(BaseModel):
    id: int
    song_name: str
    artist: str
    genre: str
    mood: str
    energy: int = Field(ge=0, le=100)
    language: str
    study_friendly: bool
    play_count: int = 0
    favorite: bool = False


class RecommendRequest(BaseModel):
    mood: str | None = None
    energy_level: int | None = Field(default=None, ge=0, le=100)
    time_of_day: str | None = None
    recently_played: list[int] = []
    skipped_songs: list[int] = []
    limit: int = Field(default=8, ge=1, le=25)


class MoodPlaylistRequest(BaseModel):
    mood: str
    study_mode: bool = False
    limit: int = Field(default=10, ge=1, le=25)


class FavoriteRequest(BaseModel):
    song_id: int
    favorite: bool = True


class HistoryRequest(BaseModel):
    song_id: int
    skipped: bool = False


class InsightResponse(BaseModel):
    top_mood: str
    top_genre: str
    favorite_count: int
    total_plays: int
    most_played: list[Song]
    mood_breakdown: dict[str, int]
    genre_breakdown: dict[str, int]
