extends Node

# Глобальные параметры
var total_death_count: int = 0 # Общее количество смертей
var zone_death_count = { # Количество смертей в каждой зоне
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
	9: 0,
	10: 0
}
var win_count: int = 0 # Количество побед

# Увеличение счётчика определённой зоны
func register_zone_death(zone_id: int):
	if zone_death_count.has(zone_id):
		zone_death_count[zone_id] += 1
