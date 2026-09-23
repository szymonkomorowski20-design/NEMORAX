extends RefCounted
class_name RewardPrompt
## Odłożone nagrody (decyzja autora 23.09): awans nie otwiera wyboru sam.
## Klawisz "open_runes" (R) / przycisk w HUD: najpierw runy do wyboru, a gdy
## ich brak — ekran punktów statystyk. Wspólne dla pokoju i areny.

static func open_runes_or_points(player: Player, skill_draft: SkillDraft, stats_screen: StatsScreen) -> void:
	if player == null:
		return
	if player.pending_skill_choices > 0:
		skill_draft.open(player)
	elif player.unspent_stat_points > 0:
		stats_screen.open(player)
	else:
		Juice.play_ui_sfx(Juice.SND_UI_ERROR)

## Tekst przycisku awansu w HUD ("" = nic nie czeka).
static func level_label(player: Player) -> String:
	var parts: Array[String] = []
	if player.pending_skill_choices > 0:
		parts.append("Runa do wyboru (%d)" % player.pending_skill_choices)
	if player.unspent_stat_points > 0:
		parts.append("Punkty: %d" % player.unspent_stat_points)
	return "  ·  ".join(parts)
