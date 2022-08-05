# rac
Regions, Areas and City for Minetest
Das ist eine neue Version von meinem rac. 
Kontrolle der Gebiete ohne ChatCommands

## Inspired by 
+ areas - ShadowNinja - https://github.com/minetest-mods/areas (Links getestet: 01.08.22, LGPL-2.1 license)
+ pvp_areas - everamzah - https://github.com/everamzah/pvp_areas (Links getestet: 01.08.22, LGPL-2.1 license)
+ landrush - Bremaweb - https://github.com/Bremaweb/landrush (Links getestet: 01.08.22, GNU LGPL version 2 / CC Attribution-ShareAlike 3.0)
+ markers - Sokomine - https://github.com/Sokomine/markers (Links getestet: 01.08.22)


# Die Idee
Ein Mod, um Gebiete anzulegen und zu schützen.
Für das Gameplay: Gebiete mit Effekten zu versehen.
Für die Builder: Gebiete als "City" zu schützen und darauf Bauplätze für Player bereitzustellen!
Zusätzlich ist es möglich auf Gebieten das PvP oder den Monsterdamage zu regeln.

Dabei werden die Gebiete nicht mehr (ausschließlich) über ChatCommands gesteuert. 
Es wurde ein RAC-Guide-Book eingeführt, über das der Spieler/Admin kontrolle über die Gebiete hat.  


Dazu kann der Players {abhängig von Privilegien}
- ein Gebiet "claimen", benennen, schützen, sowie umbenennen, einem neuen Besitzer übergeben oder löschen. 
- Gäste einladen, damit diese mit ihm zusammen auf dem (geschützten) Gebiet handeln können.
- das PvP auf den eingenen Gebieten erlauben oder verbieten
- es erlauben, dass auf seinem Gebiet die Monster keinen Schaden machen.
- sein Gebiet mit einem Effekt zu versehen (hot, breath-over-time, dot, choke, holy, evil)

|Effekt| Beschreibung | |
|-----|-----|-----|
hot| heal over time, heilt
bot | restore breath over time, gibt Atemluft
holy | beides, hot und bot 
dot| damage over time
choke | schneller verbrauch der Atemluft
evil | beides, dot und choke

## Versions
- start Juni 2022 
- v 0.8 - ein Großteil von raz ist umgeschrieben, das RAC-Guid-Book steht. 

### Roadmap
- vollständiges ReDo von raz
- Player kann über den Rac-Guide seine Gebiete anpassen
- das Claiming der Gebiete via Marker
- das Claiming der Gebiete über anclicken
 

## Privilegs:
+ - effect:				Einen Effekt für das Gebiet wählen 	
+ - mvp:					Monsterdamage auf dem Gebiet einschalten
+ -	pvp:					PVP  auf dem Gebiet einschalten (falls PVP in der Welt erlaubt ist)
+ -	guests:				Mit diesem Privileg kann der der Spieler Gäste auf sein Gebiet einladen. Die Gäste können in dem Gebiet handeln, auch wenn es geschützt ist.
+ -	set:					Ein Spieler mit dem set-Privileg kann Gebiete claimen und kann folgendes bearbeiten
--				umbenennen
--			 	Schutz ein- oder auschalten
--				Das Gebiet übertragen an einen anderen Spieler
--				Das Gebiet löschen
+ -	admin: Der Admin kann alles

## Commands



### Licence
GNU General Public License v3.0

## Textures and Models
-- könnte noch angepasst werden
Bremaweb/landrush models
- landrush_showarea.png
- landrush_showarea.x
Bremaweb/landrush textures
- landrush_landclaim.png
ShadowNinja/areas
- areas_pos1.png
- areas_pos2.png

