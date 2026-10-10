# Gamespace-godot

Kumpulan game Godot untuk materi dan tugas individu Game Development UKM.
Setiap folder adalah satu proyek Godot terpisah dan bisa langsung dibuka dari **Godot Project Manager → Import → pilih folder `project.godot`**.

- **Engine:** Godot 4.4 dan 4.6 (Forward Plus)
- **Bahasa:** GDScript
- **Kontrol umum:** `A` / `D` atau `←` / `→` untuk bergerak, `W` / `Space` / `↑` untuk melompat

## Proyek

| Folder | Proyek | Materi |
|---|---|---|
| `week2/timed-switch` | Timed Switch | Platformer berbasis waktu, kumpulkan plant dan supply sebelum timer habis |
| `week3/sg` | Shooter | Game tembak, peluru sebagai `Area2D` |
| `week4/sniper` | Sniper | Game tembak jarak jauh dengan scope |
| `quest-log` | Quest Log | Platformer dengan quest log, `QuestManager` autoload dan save/load ke `user://save.json` |
| `week-6` | Sliding Puzzle | Mekanik geser blok ke target zone dengan `PuzzleManager` autoload |
| `week-7` | Glass Floor | Lantai kaca bertingkat retak (`GlassManager` autoload, stage 0-3, tipe `delayed`/`instant`, save ke `user://glass_save.json`) |
| `week-8` | Particle Dust | `CPUParticles2D` untuk debu saat `jump`, `land`, dan `run` |
| `berbelok-dengan-efek-drift` | Berbelok dengan Efek Drift | Mobil 2D dengan fisika drift (`car.gd`, `CharacterBody2D`, `drift` + `friction` + `turn_speed`) |

## Struktur `quest-log`

| File | Fungsi |
|---|---|
| `autoload/QuestManager.gd` | Autoload yang menyimpan quest, objective, dan save/load JSON |
| `scenes/world/World.tscn` | Scene utama: langit, tanah, penempatan player dan quest log |
| `scenes/player/Player.gd` | `CharacterBody2D`, menyelesaikan objective quest lalu langsung menyimpan |
| `scenes/ui/QuestLog.gd` | Panel HUD yang menampilkan daftar quest |

## Menjalankan

1. Buka Godot 4.4 atau 4.6
2. Import folder proyek yang mau dijalankan, lalu tekan **F5**
3. Data tersimpan otomatis di folder `user://` (bisa dibuka dari `Project → File System`)

## Penulis

Seluruh proyek di repository ini dibuat sendiri sebagai tugas individu Game Development UKM.
Seluruh commit memakai satu alamat email penulis yang sama, dengan beberapa nama berbeda pada konfigurasi git lokal per mesin.

Aset pihak ketiga pada `berbelok-dengan-efek-drift` tetap mengikuti lisensinya di `berbelok-dengan-efek-drift/assets/LICENSE & CREDITS.txt`.