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

Dazu kann der Player {abhängig von Privilegien}
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

# Kurzanleitung
Jede Zone besitzt Eigenschaften, wie z. B. einen Namen, einen Besitzer, einen Zonenbezeichner.
Ist eine Position nicht geclaimed, ist sie 'Wildniss', und kann auch definiert werden.
Eigenschaften sind auch so was wie geschützt, PVP ist erlaubt oder Monster machen keinen Schaden oder einen Effekt.
Als Admin kann man erlauben, dass auf dem Gebiet andere Gebiete durch Spieler 'geclaimed' werden dürfen.

Vorgehen:
Im Vorfeld, kann man all diese Eigenschaften für die Wildniss vergeben.
z. B. in der Wildnis sollen die Monster 2-fachen Schaden machen, PVP soll erlaubt sein und man darf keine Gebiete claimen.

Als Admin kann man Regionen abstecken und diese als 'outback', 'city' oder 'plot' definieren.
Dabei gilt, dass das 'outback' eine oder mehr anderer Zonen enthalten kann. Es können nie mehr als 3 Gebiete übereinander liegen.
Das heißt, es kann an einer Position nur ein 'outback' geben, darauf kann eine 'city' und noch ein Bauplatz ('plot').

Jetzt könnte man ein 'outback' erstellen, dort machen die Monster nur noch 1.5-fachen Schaden und das PVP ist verboten.
Man könnte plots für die Spieler anlegen oder aber das Claimen durch die Spieler erlauben.

In einer 'city' könnte man den Monsterschaden auf 1fach reduzieren oder auch ganz abschalten. PVP verbieten und das Gebiet schützen, 
damit die Spieler die Infrastruktur nicht zerstören. 
In einer Stadt gibt es Bauplätze, die der Admin vorgibt. Diese können vom Spieler geclaimed werden.

## Die Spieler - Alles kann über rac-guide eingestellt werden:
Mit dem Privileg 'region_set' können auf den Gebieten mit claimable = true Gebiete besetzt/geclaimed werden.
Spieler können auch Besitzer eines Gebietes sein ohne das Privileg 'region_set', in dem sie das Gebiet übertragen bekommen.

Jeder Spieler kann sein Gebiet 'schützen', umbenennen oder löschen. Falls mehrer Spieler zusammenspielen wollen, 
können sie eingeladen werden und auch auf einem geschützten Gebiet bauen oder handeln (Privileg 'region_guests').

Gebiete der Spieler sind immer dem Zonen-Bezeichner 'owned' zugeordnet und werden von ihrem Spieler verwaltet.

Wenn der Admin das möchte, kann er Spielern auch erlauben:
- PVP auf ihren Gebieten zu erlauben/verbieten (Privileg 'region_pvp')
- den Schaden der Monster auf ihren Gebieten zu erlauben/verbieten (Privileg 'region_mvp')
- eine Effekt auf das Gebiet zu legen. Siehe Effekte, (Privileg 'region_effect')
 
## Claimen:
Mit dem Item rac:mark, setzt man an den gegenüber liegenden Ecken eines Gebietes eine Markierung. 
Hat man die nötigen Berechtigungen, wird das Gebiet automatisch geclaimed.
- mit einem Zufallsnamen
- als Geschützt markiert
- PVP, Monsterdamage und Effekt wird auf ein default gestellt. (init.lua / region_attribute.XXXX )
- für Spieler: Zone wird als 'owned' bezeichnet
- Wendet man das auf einen Plot an, wird der komplette Plot an den Spieler übertragen.
- -Vorraussetzung ist, dass der 'plot' claimable = true hat und, dass die Spieler im Plot handelsn können (protected = false)

Mit einem Plotkey, kann man einen Plot auf sich übertragen.
Der admin kann auf einem 'plot' einen Plotstone setzen, dabei wird ein zugehörenden Plotkey erzeugt. Jeder der den Plotkey hat und auf den (richtigen) Plotstone anwendet bekommt das Gebiet übertragen. 


 

## Versions
- start Juni 2022 
- v 0.8 - ein Großteil von raz ist umgeschrieben. Player kann Rac-Guide-Guid-Book nutzen.
- v 0.9 - Rac-Guide-Guid-Book für admin, Regionen stapelbar -> outback, city, plot, owned
- to do:
-	
- v 1.0 - Mobdamage je Zone, Key für Plot
 

### Roadmap
- vollständiges redo von raz
- Player kann über den Rac-Guide seine Gebiete anpassen
- Admin kann outback,City und pots erzeugen.
- das Claiming der Gebiete via Marker
- das Claiming der Gebiete über anclicken
 

## Privilegs:
+ -	admin: Der Admin kann alles
+ -	set:					Ein Spieler mit dem set-Privileg kann Gebiete claimen und kann folgendes bearbeiten
--				umbenennen
--			 	Schutz ein- oder auschalten
--				Das Gebiet an einen anderen Spieler übertragen
--				Das Gebiet löschen
+ -	guests:				Mit diesem Privileg kann der der Spieler Gäste auf sein Gebiet einladen. Die Gäste können in dem Gebiet handeln, auch wenn es geschützt ist.
+ - mvp:					Monsterdamage auf dem Gebiet einschalten
+ -	pvp:					PVP  auf dem Gebiet einschalten (falls PVP in der Welt erlaubt ist)
+ - effect:				Einen Effekt für das Gebiet wählen 	


## Commands
### all Players
+ 'region help'					all: verweist auf 'help region' und zeigt die verwendeten ChatCommands. 
+ 'region help {command} - eine Kurzbeschreibung wie das Command funktioniert
+ 'region guide' 				all: ruft den rac-guide zur Verwaltung der Regionen auf. 
+ 'region status'				all: zeigt wichtige Infos zur Region an dieser Position. 

### mit Privileg 'region_set'
+ 'region own'					all: zeigt die Region dieses Player mit ID, Region_Name, Owner, pvp und mvp Status 
+ 'region pos1'					Player mit 'region_set'/'region_admin': Setzte die erste Ecke einer möglichen neuen Region
+ 'region pos2'					Player mit 'region_set'/'region_admin': Setzte die zweite Ecke einer möglichen neuen Region
+ 'region set {name}'		Player mit 'region_set'/'region_admin': Lege eine Region mit {name} an. Davor mus pos1 und pos2 gesetz werden.
+ 'region max_y {id}'				Player mit 'region_set'/'region_admin': Setze die Region auf max Höhe, 1/3 nach unten, 2/3 nach oben
+ 'region border' 			Player: zeigt die Grenzen der eigenen Region an dieser Pos an
+ 'region change_owner {id} {player}'		Player mit 'region_set'/'region_admin': übertrage die Region {id} an {player}


### für den admin - Privileg 'region_admin'
+ 'region max_y {val}'	admin: Setze die Region auf {val} Höhe, 1/3 nach unten, 2/3 nach oben
+ 'region show'					admin: zeigt eine Liste aller Regoinen mit ID, Region_Name, Owner, pvp und mvp Status
+ 'region show {id}'		admin: zeigt die Region mit dieser ID mit ID, Region_Name, Owner, pvp und mvp Status
+ 'region show {name}'	admin: zeigt die Region dieses Player mit ID, Region_Name, Owner, pvp und mvp Status
+ 'region border' 			admin: zeigt alle Regionen an dieser Pos an, outback,city,plot/owned wird unterschiedlich angezeigt. 
+	'region border {id}'	admin: zeigt die Region mit der ID an
+ 'region compass {id}'	admin: hilft beim finden dieser ID am Ziel kommt ein 'region border {id}' 
+ 'region export'				admin: exportiert die Regionen als Datei <rac.export_file_name> ins world-Verzeichnis
+ 'region import'				admin: importiert die Regionen aus der Datei <rac.export_file_name> vom world-Verzeichnis
+ 'region player {player}'	admin: zeigt die Region dieses Player mit ID, Region_Name, Owner, pvp und mvp Status
+ 'region remove {id}'	admin: löscht die Region mit der {id}
+ 'region remove all'		admin: löscht ALLE Regionen 
+ 'region list'					admin: zeigt eine Liste aller Regionen, sortiert nach outback,city,..
+ 'region list full'		admin: zeigt zu jeder Region noch: zone, owner, name, claimable,protected, guests, pvp, mvp, effect 
+ 'region max_y {id} {neue Höhe}'				Player mit 'region_set'/'region_admin': Setze die Region auf max Höhe, 1/3 nach unten, 2/3 nach oben. Die Standardwerte sind in 'setting.lua'.
+ 'region pvp {id} {true/false}'		admin: setzt pvp der Region {id} auf true oder false
+ 'region mvp {id} {true/false}'		admin: setzt mvp (den Monsterschaden) der Region [id} auf true oder false
+ 'region claimable {id} {true/false}'		admin: setzt claimable der Region [id} auf true oder false
+ 'region protect {id} {true/false}'		admin: setzt protected der Region [id} auf true oder false
+ 'region effect {id} {effect} {add/delete}'		admin: aktiviert oder deaktiviert einen Effect auf einer Region
+ 'region change_zone {id} {zone}'		admin: setzt die Zone der {id} auf {zone}
+ 'region rename {id} {neuer Name}'		admin: Benennt die Region {id} um, auf {neuer Name}
+ 'region set_min {id} {x,y,z}'		admin: Setzte die Min-Ecke der Region auf x,y,z
+ 'region set_max {id} {x,y,z}'		admin: Setzte die Max-Ecke der Region auf x,y,z

 
## items
### plotstone
+ Auf die Regionen mit dem Zonenbezeichner 'owned' oder 'plot' kann man diesen Stein setzen.
+ - es wird eine Key erzeugt (im Inventar)
+ - der User des Key kann damit an dem Plotstone das Gebiet claimen.
+ - plotstone und key werden gelöscht. 
+ - der plotstone ist craftbar, in settings.lua kann das craften ausgeschaltet werden.

### mark
+ Diese Markierungsstangen ermöglichen es ein Gebiet zu claimen.
+ - Das Craft-Rezept kann ausgeschaltet werden.
+ - Ist in einer Region das claimable = true und hat der Spieler das Privileg region_set, kann er ein Gebiet für sich claimen.


### guide
+ Das ist ein Tool um die Regionen zu verwalten.
+ - Man muss auf der Region sein
+ - als Player kann man seine Regionen, abhängig vom Privileg, verwalten.
+ - jeder Owner kann seine REgionen verwalten
+ - Der Admin kann alles verwalten.

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

