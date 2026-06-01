from datetime import datetime

from models import Song


MOOD_ENERGY_TARGETS = {
    "calm": 30,
    "sad": 25,
    "focused": 35,
    "happy": 70,
    "energetic": 90,
    "confident": 85,
    "romantic": 55,
}


TIME_OF_DAY_BONUS = {
    "morning": {"happy": 8, "focused": 6, "energetic": 4},
    "afternoon": {"focused": 8, "happy": 5, "confident": 4},
    "evening": {"calm": 8, "romantic": 6, "sad": 3},
    "night": {"calm": 10, "focused": 5, "sad": 4},
}


def current_time_bucket() -> str:
    hour = datetime.now().hour
    if 5 <= hour < 12:
        return "morning"
    if 12 <= hour < 17:
        return "afternoon"
    if 17 <= hour < 22:
        return "evening"
    return "night"


def favorite_genres(songs: list[Song]) -> set[str]:
    return {song.genre for song in songs if song.favorite}


def score_song(
    song: Song,
    mood: str | None,
    favorite_genre_names: set[str],
    energy_level: int | None,
    time_of_day: str,
    recently_played: set[int],
    skipped_songs: set[int],
) -> float:
    """Rank a song by mood fit, user taste, context, and listening behavior."""
    score = 0.0

    if mood and song.mood == mood.lower():
        score += 35
    elif mood and song.mood in related_moods(mood):
        score += 16

    if song.genre in favorite_genre_names:
        score += 18

    target_energy = energy_level
    if target_energy is None and mood:
        target_energy = MOOD_ENERGY_TARGETS.get(mood.lower())

    if target_energy is not None:
        score += max(0, 20 - abs(song.energy - target_energy) * 0.35)

    score += TIME_OF_DAY_BONUS.get(time_of_day, {}).get(song.mood, 0)

    if song.study_friendly and mood in {"focused", "calm"}:
        score += 8

    score += min(song.play_count, 40) * 0.2

    if song.id in recently_played:
        score -= 20

    if song.id in skipped_songs:
        score -= 35

    if song.favorite:
        score += 7

    return score


def related_moods(mood: str) -> set[str]:
    mood_map = {
        "calm": {"focused", "romantic"},
        "sad": {"calm", "romantic"},
        "focused": {"calm"},
        "happy": {"confident", "energetic"},
        "energetic": {"happy", "confident"},
        "confident": {"happy", "energetic"},
        "romantic": {"calm", "sad"},
    }
    return mood_map.get(mood.lower(), set())


def recommend_songs(
    songs: list[Song],
    mood: str | None = None,
    energy_level: int | None = None,
    time_of_day: str | None = None,
    recently_played: list[int] | None = None,
    skipped_songs: list[int] | None = None,
    limit: int = 8,
) -> list[Song]:
    time_bucket = (time_of_day or current_time_bucket()).lower()
    favorite_genre_names = favorite_genres(songs)
    recent_ids = set(recently_played or [])
    skipped_ids = set(skipped_songs or [])

    ranked = sorted(
        songs,
        key=lambda song: score_song(
            song=song,
            mood=mood,
            favorite_genre_names=favorite_genre_names,
            energy_level=energy_level,
            time_of_day=time_bucket,
            recently_played=recent_ids,
            skipped_songs=skipped_ids,
        ),
        reverse=True,
    )
    return ranked[:limit]


def mood_playlist(songs: list[Song], mood: str, study_mode: bool = False, limit: int = 10) -> list[Song]:
    mood_name = mood.lower()
    matches = [song for song in songs if song.mood == mood_name]

    if study_mode:
        matches = [song for song in matches if song.study_friendly]

    if len(matches) < limit:
        related = [
            song
            for song in songs
            if song.mood in related_moods(mood_name) and (song.study_friendly or not study_mode)
        ]
        matches.extend(related)

    return sorted(matches, key=lambda song: (song.favorite, song.play_count), reverse=True)[:limit]
