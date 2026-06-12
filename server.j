// ============================================
// MATCH NIGHT TACTICAL SIMULATOR - BACKEND
// ============================================
// Bu basit sunucu, API-FOOTBALL'a yapılan istekleri
// güvenli şekilde yönlendirir (proxy). API key burada
// gizli kalır, tarayıcıya hiç gönderilmez.

const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors()); // Frontend'in (HTML dosyamız) buraya istek atabilmesi için

// ----------------------------------------------
// API KEY - Render'da "Environment Variable" olarak
// ekleyeceğiz (kod içine yazmıyoruz, güvenlik için).
// dashboard.api-football.com üzerinden alınan key kullanılıyor.
// ----------------------------------------------
const API_KEY = process.env.API_FOOTBALL_KEY;
const BASE_URL = 'https://v3.football.api-sports.io';
const API_HEADERS = {
  'x-apisports-key': API_KEY
};

// Basit bir sağlık kontrolü - sunucu çalışıyor mu test etmek için
app.get('/', (req, res) => {
  res.json({ status: 'Match Night backend çalışıyor ✅' });
});

// ----------------------------------------------
// ENDPOINT 1: Takım ara (isimden takım ID bulmak için)
// Örnek kullanım: /api/teams?search=fenerbahce
// ----------------------------------------------
app.get('/api/teams', async (req, res) => {
  try {
    const search = req.query.search || '';
    const response = await fetch(`${BASE_URL}/teams?search=${encodeURIComponent(search)}`, {
      headers: API_HEADERS
    });
    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: 'Takım araması başarısız', details: err.message });
  }
});

// ----------------------------------------------
// ENDPOINT 2: Bir takımın son tamamlanmış maçlarını getir
// Örnek kullanım: /api/last-fixtures?teamId=611&count=5
// ----------------------------------------------
app.get('/api/last-fixtures', async (req, res) => {
  try {
    const teamId = req.query.teamId;
    const count = req.query.count || 5;
    const response = await fetch(`${BASE_URL}/fixtures?team=${teamId}&last=${count}`, {
      headers: API_HEADERS
    });
    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: 'Maç listesi alınamadı', details: err.message });
  }
});

// ----------------------------------------------
// ENDPOINT 3: Tek bir maçın detaylı verisi
// (skor, istatistikler, gol dakikaları)
// Örnek kullanım: /api/fixture?fixtureId=12345
// ----------------------------------------------
app.get('/api/fixture', async (req, res) => {
  try {
    const fixtureId = req.query.fixtureId;

    // Maçın temel bilgisi + goller
    const fixtureResp = await fetch(`${BASE_URL}/fixtures?id=${fixtureId}`, {
      headers: API_HEADERS
    });
    const fixtureData = await fixtureResp.json();

    // Maç istatistikleri (xG, şut, top hakimiyeti vb.)
    const statsResp = await fetch(`${BASE_URL}/fixtures/statistics?fixture=${fixtureId}`, {
      headers: API_HEADERS
    });
    const statsData = await statsResp.json();

    res.json({
      fixture: fixtureData,
      statistics: statsData
    });
  } catch (err) {
    res.status(500).json({ error: 'Maç verisi alınamadı', details: err.message });
  }
});

// ----------------------------------------------
// Sunucuyu başlat
// ----------------------------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend ${PORT} portunda çalışıyor`);
});
