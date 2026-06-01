const state = {
  songs: [],
  recommendations: [],
  playlist: [],
  favorites: [],
  history: [],
  insights: null,
  selectedMood: "focused",
  skippedSongs: [],
  nowPlaying: null
};

const moods = [
  ["calm", "☁", "var(--mint)", 30],
  ["focused", "◈", "var(--lavender)", 35],
  ["happy", "☀", "var(--butter)", 70],
  ["energetic", "ϟ", "var(--blush)", 90],
  ["confident", "✦", "#cab2ff", 85],
  ["sad", "☾", "var(--blue)", 25],
  ["romantic", "♡", "#ffc0d5", 55]
];

const relatedMoods = {
  calm: ["focused", "romantic"],
  sad: ["calm", "romantic"],
  focused: ["calm"],
  happy: ["confident", "energetic"],
  energetic: ["happy", "confident"],
  confident: ["happy", "energetic"],
  romantic: ["calm", "sad"]
};

function titleCase(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}

function switchView(name) {
  document.querySelectorAll(".tab").forEach((tab) => {
    tab.classList.toggle("is-active", tab.dataset.view === name);
  });
  document.querySelectorAll(".view").forEach((view) => {
    view.classList.toggle("is-visible", view.id === `${name}-view`);
  });
}

function favoriteGenres() {
  return new Set(state.songs.filter((song) => song.favorite).map((song) => song.genre));
}

function scoreSong(song, mood, targetEnergy) {
  let score = 0;
  const favorites = favoriteGenres();

  if (song.mood === mood) score += 35;
  if ((relatedMoods[mood] || []).includes(song.mood)) score += 16;
  if (favorites.has(song.genre)) score += 18;
  if (targetEnergy !== undefined) score += Math.max(0, 20 - Math.abs(song.energy - targetEnergy) * 0.35);
  if (song.study_friendly && ["focused", "calm"].includes(mood)) score += 8;
  if (song.favorite) score += 7;
  score += Math.min(song.play_count, 40) * 0.2;
  if (state.history.slice(0, 6).some((played) => played.id === song.id)) score -= 20;
  if (state.skippedSongs.includes(song.id)) score -= 35;

  return score;
}

function recommend(mood = state.selectedMood, targetEnergy = 35, limit = 8) {
  return [...state.songs]
    .sort((a, b) => scoreSong(b, mood, targetEnergy) - scoreSong(a, mood, targetEnergy))
    .slice(0, limit);
}

function createPlaylist(mood, studyMode, limit = 10) {
  const direct = state.songs.filter((song) => song.mood === mood && (!studyMode || song.study_friendly));
  const related = state.songs.filter(
    (song) => (relatedMoods[mood] || []).includes(song.mood) && (!studyMode || song.study_friendly)
  );

  return [...direct, ...related]
    .sort((a, b) => Number(b.favorite) - Number(a.favorite) || b.play_count - a.play_count)
    .slice(0, limit);
}

function buildInsights() {
  const moodBreakdown = {};
  const genreBreakdown = {};

  state.songs.forEach((song) => {
    if (song.play_count <= 0) return;
    moodBreakdown[song.mood] = (moodBreakdown[song.mood] || 0) + 1;
    genreBreakdown[song.genre] = (genreBreakdown[song.genre] || 0) + 1;
  });

  const topEntry = (data) => Object.entries(data).sort((a, b) => b[1] - a[1])[0]?.[0] || "No plays yet";

  return {
    top_mood: topEntry(moodBreakdown),
    top_genre: topEntry(genreBreakdown),
    favorite_count: state.songs.filter((song) => song.favorite).length,
    total_plays: state.songs.reduce((sum, song) => sum + song.play_count, 0),
    most_played: [...state.songs].sort((a, b) => b.play_count - a.play_count).slice(0, 5),
    mood_breakdown: moodBreakdown,
    genre_breakdown: genreBreakdown
  };
}

function songCard(song, compact = false) {
  const card = document.createElement("article");
  card.className = "song-card";
  card.innerHTML = `
    <div class="cover">${song.study_friendly ? "♫" : "♪"}</div>
    <div class="song-main">
      <strong>${song.song_name}</strong>
      <div class="song-meta">${song.artist} • ${song.genre}</div>
      <div class="song-tags">${titleCase(song.mood)} • ${song.energy}% energy • ${song.play_count} plays</div>
    </div>
  `;

  if (!compact) {
    const actions = document.createElement("div");
    actions.className = "actions";

    const favorite = document.createElement("button");
    favorite.className = `icon-button ${song.favorite ? "is-favorite" : ""}`;
    favorite.type = "button";
    favorite.title = "Favorite";
    favorite.textContent = song.favorite ? "♥" : "♡";
    favorite.addEventListener("click", () => toggleFavorite(song));

    const play = document.createElement("button");
    play.className = "icon-button primary";
    play.type = "button";
    play.title = "Play";
    play.textContent = "▶";
    play.addEventListener("click", () => playSong(song));

    actions.append(favorite, play);
    card.append(actions);
  }

  return card;
}

function renderSongList(selector, songs, compact = false, empty = "Nothing here yet.") {
  const list = document.querySelector(selector);
  list.innerHTML = "";
  if (!songs.length) {
    const panel = document.createElement("div");
    panel.className = "panel";
    panel.textContent = empty;
    list.append(panel);
    return;
  }
  songs.forEach((song) => list.append(songCard(song, compact)));
}

function renderMoods() {
  const grid = document.querySelector("#mood-grid");
  grid.innerHTML = "";
  moods.forEach(([name, icon, color, energy]) => {
    const button = document.createElement("button");
    button.className = "mood-card";
    button.type = "button";
    button.style.background = color;
    button.innerHTML = `<strong>${icon} ${titleCase(name)}</strong><span>${energy}% target energy</span>`;
    button.addEventListener("click", () => generatePlaylist(name, energy));
    grid.append(button);
  });
}

function renderInsights() {
  const metrics = document.querySelector("#metrics");
  metrics.innerHTML = "";
  if (!state.insights) return;

  [
    ["Top Mood", titleCase(state.insights.top_mood), "☻"],
    ["Top Genre", state.insights.top_genre, "♬"],
    ["Favorites", state.insights.favorite_count, "♥"],
    ["Total Plays", state.insights.total_plays, "▶"]
  ].forEach(([label, value, icon]) => {
    const card = document.createElement("div");
    card.className = "metric";
    card.innerHTML = `<span>${icon}</span><b>${value}</b><strong>${label}</strong>`;
    metrics.append(card);
  });

  renderSongList("#most-played", state.insights.most_played, true);
}

function renderAll() {
  state.favorites = state.songs.filter((song) => song.favorite);
  state.insights = buildInsights();
  renderSongList("#recommendations", state.recommendations, false, "Pick a mood to refresh recommendations.");
  renderSongList("#playlist", state.playlist, false, "Pick a mood to generate a playlist.");
  renderSongList("#favorites", state.favorites, false, "Tap a heart to save a song.");
  renderInsights();

  document.querySelector("#playlist-title").textContent = `${titleCase(state.selectedMood)} Playlist`;
  const now = document.querySelector("#now-playing");
  if (state.nowPlaying) {
    now.innerHTML = `
      <span class="pulse"></span>
      <div><strong>${state.nowPlaying.song_name}</strong><p>${state.nowPlaying.artist} is now playing.</p></div>
    `;
  }
}

async function loadInitialData() {
  const response = await fetch("./sample_songs.json");
  state.songs = await response.json();
  state.recommendations = recommend("focused", 35);
  state.playlist = createPlaylist("focused", false);
  renderAll();
}

function generatePlaylist(mood, energy) {
  const studyMode = document.querySelector("#study-mode").checked;
  state.selectedMood = mood;
  state.playlist = createPlaylist(mood, studyMode);
  state.recommendations = recommend(mood, energy);
  renderAll();
  switchView("playlist");
}

function toggleFavorite(song) {
  const saved = state.songs.find((item) => item.id === song.id);
  saved.favorite = !saved.favorite;
  state.recommendations = recommend(state.selectedMood);
  state.playlist = createPlaylist(state.selectedMood, document.querySelector("#study-mode").checked);
  renderAll();
}

function playSong(song) {
  const saved = state.songs.find((item) => item.id === song.id);
  saved.play_count += 1;
  state.nowPlaying = saved;
  state.history.unshift(saved);
  state.history = state.history.slice(0, 20);
  state.recommendations = recommend(state.selectedMood);
  renderAll();
}

document.querySelectorAll(".tab").forEach((tab) => {
  tab.addEventListener("click", () => switchView(tab.dataset.view));
});

renderMoods();
loadInitialData();
