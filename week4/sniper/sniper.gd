extends CharacterBody2D

# =============================================================================
# SNIPER AI — Finite State Machine
#
# Filosofi AI:
#   Sniper adalah penembak jarak jauh yang PENGECUT tapi BERBAHAYA.
#   - Dia TIDAK MAU bertarung jarak dekat
#   - Selalu jaga jarak >= safe_distance dari player
#   - Baru menembak setelah posisi aman terpenuhi
#   - Kalau player mendekat saat apapun → kabur dulu, tembak kemudian
#
# Alur state:
#   IDLE ──(player masuk detect_radius)──► REPOSITION
#   REPOSITION ──(posisi aman tercapai)──► AIM
#   AIM ──(aim_time selesai)────────────► SHOOT
#   SHOOT ──(cooldown selesai)──────────► REPOSITION  (tembak lagi)
#   SHOOT ──(player keluar detect)──────► IDLE
#   [REPOSITION/AIM/SHOOT] ──(player terlalu dekat)──► REPOSITION (kabur)
# =============================================================================

@export var speed          : float = 140.0
@export var safe_distance  : float = 300.0  # jarak MINIMAL dari player
@export var ideal_distance : float = 380.0  # jarak IDEAL untuk menembak
@export var detect_radius  : float = 500.0  # radius mulai aktif
@export var aim_time       : float = 1.2    # detik ancang-ancang sebelum tembak
@export var shoot_cooldown : float = 2.0    # detik cooldown setelah tembak
@export var bullet_scene   : PackedScene

# ── State ─────────────────────────────────────────────────────────────────────
enum State { IDLE, REPOSITION, AIM, SHOOT }
var state : State = State.IDLE

# ── Node refs ─────────────────────────────────────────────────────────────────
@onready var nav_agent    : NavigationAgent2D = $NavigationAgent2D
@onready var bullet_spawn : Marker2D          = $BulletSpawnPoint

# ── Runtime vars ──────────────────────────────────────────────────────────────
var player        : Node2D = null
var aim_timer     : float  = 0.0
var shoot_timer   : float  = 0.0
var shoot_done    : bool   = false
var reposition_target : Vector2 = Vector2.ZERO

# =============================================================================
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	# NavigationAgent2D perlu 1 physics frame agar navigation map terdaftar
	# ke NavigationServer. Sebelum frame ini, get_next_path_position() selalu
	# mengembalikan posisi agent itu sendiri → velocity nol → sniper diam.
	await get_tree().physics_frame

# =============================================================================
func _physics_process(delta: float) -> void:
	if player == null:
		return

	var dist : float = global_position.distance_to(player.global_position)

	match state:

		# ── IDLE ──────────────────────────────────────────────────────────────
		# Sniper diam, tidak peduli lingkungan.
		# Begitu player masuk detect_radius → masuk REPOSITION.
		# REPOSITION (bukan langsung AIM) karena sniper belum tentu
		# berada di posisi aman saat pertama kali mendeteksi player.
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()

			if dist <= detect_radius:
				_enter_reposition()

		# ── REPOSITION ────────────────────────────────────────────────────────
		# Sniper bergerak ke titik ideal_distance dari player.
		# Titik ini dihitung sekali saat masuk state, lalu dipertahankan
		# sampai tercapai atau player bergerak terlalu jauh/dekat.
		#
		# Kenapa tidak update target setiap frame?
		# Kalau target di-update setiap frame mengikuti player yang bergerak,
		# NavigationAgent terus reset path → sniper bergetar/glitchy karena
		# path belum selesai dihitung sudah diganti lagi.
		# Target di-update hanya kalau sudah sampai atau kondisi berubah drastis.
		State.REPOSITION:
			# Player kabur keluar radar → balik IDLE
			if dist > detect_radius:
				state = State.IDLE
				velocity = Vector2.ZERO
				move_and_slide()
				return

			var at_target : bool = nav_agent.is_navigation_finished() or \
				global_position.distance_to(reposition_target) < 30.0

			if at_target:
				# Sudah sampai di target reposition
				if dist >= safe_distance:
					# Posisi aman → mulai bidik
					_enter_aim()
				else:
					# Masih terlalu dekat (misal player ikut mengejar) → cari target baru
					_compute_reposition_target()
			else:
				# Sedang bergerak menuju target
				if dist < safe_distance:
					# Player menyusul terlalu dekat → recalculate target lebih jauh
					_compute_reposition_target()

				var next_pos : Vector2 = nav_agent.get_next_path_position()
				velocity = (next_pos - global_position).normalized() * speed
				move_and_slide()

		# ── AIM ───────────────────────────────────────────────────────────────
		# Sniper berhenti, menghadap player, mulai ancang-ancang.
		# Selama aim, sniper TETAP memantau jarak. Kalau player mendekat → kabur.
		# Sniper tidak bergerak saat aim agar tembakan akurat.
		State.AIM:
			velocity = Vector2.ZERO
			move_and_slide()
			look_at(player.global_position)

			if dist < safe_distance:
				# Player mendekat → prioritas kabur, reset timer
				_enter_reposition()
				return

			if dist > detect_radius:
				# Player kabur → balik IDLE
				aim_timer = 0.0
				state = State.IDLE
				return

			aim_timer += delta
			if aim_timer >= aim_time:
				_enter_shoot()

		# ── SHOOT ─────────────────────────────────────────────────────────────
		# Tembak 1x saat masuk state. Tunggu cooldown.
		# Setelah cooldown: REPOSITION lagi agar sniper tidak diam di tempat
		# dan terus mencari sudut tembak baru (lebih dinamis).
		State.SHOOT:
			velocity = Vector2.ZERO
			move_and_slide()
			look_at(player.global_position)

			if dist < safe_distance:
				_enter_reposition()
				return

			# Tembak hanya 1x
			if not shoot_done:
				_fire()
				shoot_done = true

			shoot_timer += delta
			if shoot_timer >= shoot_cooldown:
				# Cooldown selesai
				if dist > detect_radius:
					state = State.IDLE
				else:
					# Meski player masih dalam radius, reposition dulu
					# agar sniper pindah posisi → lebih susah diprediksi
					_enter_reposition()

# =============================================================================
# Helper: hitung dan set target reposition ke NavigationAgent
# =============================================================================
func _compute_reposition_target() -> void:
	# Cari titik di ideal_distance dari player, di sisi BERLAWANAN dengan arah
	# sniper-ke-player. Dengan begitu sniper tidak cuma mundur lurus tapi
	# mencoba menjaga sudut tembak yang baik.
	var away_dir : Vector2 = (global_position - player.global_position).normalized()

	# Tambahkan sedikit offset lateral agar sniper tidak hanya mundur lurus
	# (bisa terhalang dinding yang sama). Offset berganti-ganti kiri/kanan
	# berdasarkan waktu untuk variasi pergerakan.
	var lateral : Vector2 = away_dir.rotated(PI * 0.25 * sign(sin(Time.get_ticks_msec() * 0.001)))
	var blended  : Vector2 = (away_dir + lateral * 0.4).normalized()

	reposition_target = player.global_position + blended * ideal_distance
	nav_agent.target_position = reposition_target

# =============================================================================
# Helper: transisi masuk state (reset semua timer)
# =============================================================================
func _enter_reposition() -> void:
	aim_timer   = 0.0
	shoot_timer = 0.0
	shoot_done  = false
	state = State.REPOSITION
	_compute_reposition_target()

func _enter_aim() -> void:
	aim_timer   = 0.0
	shoot_timer = 0.0
	shoot_done  = false
	state = State.AIM

func _enter_shoot() -> void:
	aim_timer   = 0.0
	shoot_timer = 0.0
	shoot_done  = false
	state = State.SHOOT

# =============================================================================
# Fire: spawn bullet dengan arah eksplisit (bukan via rotation)
# =============================================================================
func _fire() -> void:
	if bullet_scene == null:
		push_warning("Sniper: bullet_scene belum di-assign di Inspector!")
		return

	var b   : Node    = bullet_scene.instantiate()
	var dir : Vector2 = (player.global_position - bullet_spawn.global_position).normalized()

	# PENTING: set posisi SEBELUM add_child agar global_position valid.
	# Arah disimpan sebagai Vector2 (bukan rotation) karena bullet di-add ke
	# root scene — rotasi parent tidak diwarisi, sehingga
	# Vector2.RIGHT.rotated(rotation) di bullet.gd bisa salah arah.
	b.global_position = bullet_spawn.global_position
	b.direction       = dir         # Vector2 eksplisit → selalu benar
	b.rotation        = dir.angle() # untuk visual sprite saja
	b.shooter         = self        # bullet mengabaikan collision dengan sniper ini

	get_tree().current_scene.add_child(b)
