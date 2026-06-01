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

const API_BASE = "http://127.0.0.1:8000";

const moods = [
  ["calm", "☁", "var(--mint)", 30],
  ["focused", "◈", "var(--lavender)", 35],
  ["happy", "☀", "var(--butter)", 70],
  ["energetic", "ϟ", "var(--blush)", 90],
  ["confident", "✦", "#cab2ff", 85],
  ["sad", "☾", "var(--blue)", 25],
  ["romantic", "♡", "#ffc0d5", 55]
];

const api = {
  async get(path) {
    const response = await fetch(`${API_BASE}${path}`);
    if (!response.ok) throw new Error(path);
    return response.json();
  },
  async post(path, body) {
    const response = await fetch(`${API_BASE}${path}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
    if (!response.ok) throw new Error(path);
    return response.json();
  }
};

function titleCase(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}

function showStatus(message, isError = false) {
  const status = document.querySelector("#status");
  status.textContent = message;
  status.classList.toggle("is-visible", Boolean(message));
  status.style.background = isError ? "rgba(240, 111, 134, 0.84)" : "rgba(169, 232, 209, 0.78)";
}

function switchView(name) {
  document.querySelectorAll(".tab").forEach((tab) => {
    tab.classList.toggle("is-active", tab.dataset.view === name);
  });
  document.querySelectorAll(".view").forEach((view) => {
    view.classList.toggle("is-visible", view.id === `${name}-view`);
  });
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
  renderSongList("#recommendations", state.recommendations, false, "Start the backend and refresh recommendations.");
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
  try {
    showStatus("Connecting to MuseCore API...");
    const [songs, favorites, history, insights] = await Promise.all([
      api.get("/songs"),
      api.get("/favorites"),
      api.get("/history"),
      api.get("/insights")
    ]);
    state.songs = songs;
    state.favorites = favorites;
    state.history = history;
    state.insights = insights;
    state.recommendations = await api.post("/recommend", {
      mood: state.selectedMood,
      energy_level: 35,
      recently_played: state.history.map((song) => song.id),
      skipped_songs: state.skippedSongs,
      limit: 8
    });
    state.playlist = await api.post("/mood-playlist", {
      mood: state.selectedMood,
      study_mode: false,
      limit: 10
    });
    showStatus("");
    renderAll();
  } catch (error) {
    showStatus("Could not connect to the MuseCore API. Restart FastAPI and refresh.", true);
  }
}

async function generatePlaylist(mood, energy) {
  const studyMode = document.querySelector("#study-mode").checked;
  state.selectedMood = mood;
  state.playlist = await api.post("/mood-playlist", {
    mood,
    study_mode: studyMode,
    limit: 10
  });
  state.recommendations = await api.post("/recommend", {
    mood,
    energy_level: energy,
    recently_played: state.history.map((song) => song.id),
    skipped_songs: state.skippedSongs,
    limit: 8
  });
  renderAll();
  switchView("playlist");
}

async function toggleFavorite(song) {
  await api.post("/favorites", {
    song_id: song.id,
    favorite: !song.favorite
  });
  await refreshDynamicData();
}

async function playSong(song) {
  state.nowPlaying = await api.post("/history", {
    song_id: song.id,
    skipped: false
  });
  await refreshDynamicData();
}

async function refreshDynamicData() {
  const [songs, favorites, history, insights] = await Promise.all([
    api.get("/songs"),
    api.get("/favorites"),
    api.get("/history"),
    api.get("/insights")
  ]);
  state.songs = songs;
  state.favorites = favorites;
  state.history = history;
  state.insights = insights;
  state.recommendations = await api.post("/recommend", {
    mood: state.selectedMood,
    recently_played: state.history.map((song) => song.id),
    skipped_songs: state.skippedSongs,
    limit: 8
  });
  if (state.nowPlaying) {
    state.nowPlaying = state.songs.find((song) => song.id === state.nowPlaying.id) || state.nowPlaying;
  }
  renderAll();
}

document.querySelectorAll(".tab").forEach((tab) => {
  tab.addEventListener("click", () => switchView(tab.dataset.view));
});

renderMoods();
loadInitialData();
