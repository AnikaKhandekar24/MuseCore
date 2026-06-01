import json
from collections import Counter
from pathlib import Path

from models import Song


DATA_FILE = Path(__file__).with_name("sample_songs.json")


class MusicDatabase:
    """Small JSON-backed database for a student portfolio backend."""

    def __init__(self, data_file: Path = DATA_FILE):
        self.data_file = data_file
        self._songs: list[Song] = self._load_songs()
        self.history: list[dict] = []

    def _load_songs(self) -> list[Song]:
        with self.data_file.open("r", encoding="utf-8") as file:
            raw_songs = json.load(file)
        return [Song(**song) for song in raw_songs]

    def _save_songs(self) -> None:
        with self.data_file.open("w", encoding="utf-8") as file:
            json.dump([song.model_dump() for song in self._songs], file, indent=2)

    def all_songs(self) -> list[Song]:
        return self._songs

    def get_song(self, song_id: int) -> Song | None:
        return next((song for song in self._songs if song.id == song_id), None)

    def favorite_songs(self) -> list[Song]:
        return [song for song in self._songs if song.favorite]

    def set_favorite(self, song_id: int, favorite: bool) -> Song | None:
        song = self.get_song(song_id)
        if song is None:
            return None

        song.favorite = favorite
        self._save_songs()
        return song

    def add_history(self, song_id: int, skipped: bool = False) -> Song | None:
        song = self.get_song(song_id)
        if song is None:
            return None

        if not skipped:
            song.play_count += 1
            self._save_songs()

        self.history.insert(0, {"song_id": song_id, "skipped": skipped})
        self.history = self.history[:50]
        return song

    def recently_played_ids(self, count: int = 10) -> list[int]:
        recent = [item["song_id"] for item in self.history if not item["skipped"]]
        return recent[:count]

    def skipped_ids(self, count: int = 10) -> list[int]:
        skipped = [item["song_id"] for item in self.history if item["skipped"]]
        return skipped[:count]

    def insights(self) -> dict:
        played_songs = [song for song in self._songs if song.play_count > 0]
        mood_counts = Counter(song.mood for song in played_songs)
        genre_counts = Counter(song.genre for song in played_songs)

        top_mood = mood_counts.most_common(1)[0][0] if mood_counts else "No plays yet"
        top_genre = genre_counts.most_common(1)[0][0] if genre_counts else "No plays yet"
        most_played = sorted(self._songs, key=lambda song: song.play_count, reverse=True)[:5]

        return {
            "top_mood": top_mood,
            "top_genre": top_genre,
            "favorite_count": len(self.favorite_songs()),
            "total_plays": sum(song.play_count for song in self._songs),
            "most_played": most_played,
            "mood_breakdown": dict(mood_counts),
            "genre_breakdown": dict(genre_counts),
        }
