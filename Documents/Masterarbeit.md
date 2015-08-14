# Einleitung

Das \glspl{DLR} erforscht am Institut für Luftfahrtsysteme in der Abteilung für Unbemannte Luftfahrzeuge die automatisierte Bewegung von \gls{UA} in unbekanntem Luftraum. Anforderungen an das automatisierte System sind die Wahrnehmung der Umwelt, die Bestimmung der eigenen Position und Lage (Pose) im Raum und entsprechende Entscheidungen für die Erfüllung einer bestimmten Mission ableiten. Die Grundvoraussetzung zur Umwelt- und Selbstwahrnehmung ist eine gemeinsame Datenbasis der Sensordaten. Dadurch können die verschiedenen Sensorwerte zueinander in Verbindung gebracht werden. Für eine konsistente Datenfusion müssen die Positionen, Eigenschaften und Fehler der verschiedenen Sensoren bekannt sein. Eine Fusion der Daten wird erschwert wenn:

- je nach Flugauftrag variable Grundkonfigurationen (verschiedene Sensoren) verwendet werden,
- je nach Umgebung unterschiedliche Trägersysteme eingesetzt werden (Größen- oder Gewichtsbestimmungen)
- Beladungszustände variieren, die eine Austarierung der Sensoren erfordern.

Einige dieser Probleme können gelöst werden, wenn zu jedem Experiment der Aufbau der Sensorplattform vermessen oder durch eine Konstruktionszeichnungen festgelegt wird. Im Anschluss müssen die erhaltenen Daten in die Sensorfusion eingepflegt und eventuell manuell angepasst werden.

Dieses Vorgehen ist aufwendig, fehleranfällig und je nach \gls{UA} schwer umsetzbar. Eine ungenaue Kalibrierung führt bei einer Abweichung von $1°$ bereits zu einem Fehler von $m$ auf einer Entfernung von $m$. Der in dieser Arbeit vorgestellte Ansatz ermöglicht die Bestimmung der Montageparameter von Laserscannern relativ zu einem Navigationssystem (\gls{IMU} und \gls{GPS}). Die grundlegende Idee besteht darin, Unterschiede in sequentiellen Laserscans mit der gemessenen Bewegung des \gls{UA} zu vergleichen. Für diese Lösung wird eine während der Kalibrierung statische Konfiguration vorausgesetzt. Das bedeutet, dass Laserscanner und die Navigationssensoren zueinander statisch, auf der gleichen Trägerplattform befestigt sind.

Für diese Arbeit wird folgende Forschungsfrage formuliert: *"Ist es möglich, bildgebende Sensoren anhand von visuellen Merkmalen relativ zu gleichzeitig aufgezeichneten Bewegungsdaten zu kalibrieren?"* Der präsentierte Ansatz zur Kalibrierung von Laserscannern zu Navigationsdaten soll eine Identifikation des Systems mit seiner Umwelt ermöglichen und das System befähigen, seine Bewegung im Raum mit den Sensordaten zu verknüpfen.

Dazu werden Laserdaten während der Bewegung sequentiell mit einem \gls{ICP}-Algorithmus registriert, das heißt aneinander angeglichen. Der Algorithmus berechnet eine Transformation, die im Zusammenhang zur durchgeführten Bewegung steht. Parallel zur Registrierung der Laserscans werden Navigationsdaten mittels einer \gls{IMU} und einem \gls{GPS} aufgezeichnet. Aus diesen Daten wird eine Bewegungstransformation bestimmt und im Anschluss mit der \gls{ICP}-Transformation verglichen. Da sich beide Sensoren zueinander statisch auf einer Plattform befinden, ist die Differenz das Resultat einer unterschiedlichen Montagepose zwischen Laserscanner und \gls{IMU}.

Die folgenden Kapitel geben einen Einblick in die physikalischen Grundlagen der verwendeten Sensoren und den mathematischen Grundlagen zur Verarbeitung der Messungen. Im Anschluss wird der Ansatz zur relativen extrinsischen Kalibrierung präsentiert, der während der Masterarbeit als Filter im \gls{DIP}-Framework^[Das \gls{DIP}-Framework dient seit 2004 als Plattform zur Evaluation digitaler Bildverarbeitungsalgorithmen in der Abteilung \gls{ULF} am \gls{DLR}. Für weitere Informationen zur grundlegenden Idee und den Hintergründen des Frameworks siehe @Guth2004 und @Goormann2004.] implementiert wurde. Den Abschluss bildet die Validierung der Kalibrierung in zwei voneinander unabhängigen Experimenten.

# Grundlagen
## Mathematik und Geometrie
### Matrizenrechnung

### Transformation von Koordinatensystemen



### Nichtlineare Optimierung nach Levenberg-Marquardt
#### Theoretische Funktionsweise
#### Varianten der Optimierung
#### Grenzen des Algorithmus
## Sensortechnik
### Visuelle Odometrie durch LiDAR-Sensoren

Umweltwahrnehmung ist für Lebewesen, wie den Menschen, eine überlebenswichtige Fähigkeit. Durch unsere Sinne erkennen wir unser Umfeld, können die Umgebung klassifizieren und bedrohliche Situationen erkennen. Bedrohlich bezeichnet dabei Situationen, in denen entweder wir, unsere Mitmenschen oder Ziele eines Auftrags gefährdet sind. Ein großer Bestandteil unserer Wahrnehmung ist visuell und erfolgt durch unsere Augen.

In automatisierten Systeme werden bildgebende Sensoren zur visuellen Wahrnehmung verwendet. Diese Sensoren erstellen in zeitlichen Abständen ein Bild, dass aus Messgrößen eines realen Objektes besteht. Die Messgröße oder eine daraus abgeleitete Information ist ortsaufgelöst und wird über Helligkeitswerte oder Farben kodiert visualisiert.

Die visuelle Odometrie, auch Ego-Motion (engl.), bezeichnet das Fachgebiet zur Schätzung von Bewegungen aus Bildinformationen. Dabei werden Veränderungen von Merkmalen (Features) aus verschiedenen Aufnahmen der Umwelt bestimmt. Welche Merkmale verwendet werden, ist abhängig von der Struktur der eingegebenen Daten.

Man unterscheidet organisierte und unorganisierte Datensätze. Organisierte Daten sind aufeinanderfolgende Messungen, wie sie bei einem Bild einer Digitalkamera vorliegen. Die Bildinformationen liegen dabei, durch unterschiedliche optische Eigenschaften, in einer festen Zahl von Zeilen und Spalten vor. Unorganisierte Datensätze weisen diese Eigenschaft nicht vor, sodass kein lokaler Zusammenhang zwischen zwei aufeinanderfolgenden Daten bestehen muss.

Des Weiteren ist die Erkennung von Merkmalen abhängig von der Qualität der vorliegenden Messungen. Qualität bezeichnet dabei das Zueinanderpassen mehrerer Datensätze. Unterschiede die durch Rotation, Translation, Skalierung oder Messrauschen verursacht werden, erfordern unterschiedliche Ansätze zur Extraktion von Merkmalen. In dieser Arbeit werden statische Umgebungen vorausgesetzt. Das heißt, dass Unterschiede zwischen verschiedenen Bildern rein aus der Bewegung des Trägers und systembedingte Messfehler resultieren.

#### Exemplarischer Aufbau und Funktionsweise eines LiDARs

\gls{LiDAR} dienen der optischen Abstandsmessung. Einsatzgebiete sind unter Anderem topographische Geländeaufnahmen (Kartographie) [@Lindenberger1993], Detektion und Tracking von Hindernissen [@Mendes2004] und Identifikation atmosphärischer Eigenschaften [@Wulfmeyer1998; @Browell1998].

Ein \gls{LiDAR} besteht gemäß Abbildung @fig:aufbau_LiDAR aus einer Laserquelle, einem Laserdetektor und einem Gehäuse. Die Laserquelle erzeugt durch „Pumpen“ energiereiches Licht, dass anschließend gepulst das Gehäuse verlässt.

<!-- ![Images/Exemplarischer Aufbau eines \gls{LiDAR} (schematisch)]() #fig:aufbau_LiDAR -->

##### Optische Eigenschaften des Lasers

Laserlicht entsteht durch Absorption und spontane sowie stimulierte Emission von Ladungsträgern in einem aktiven Material, wie Feststoff oder Gas. Durch die Emission entstehen im Laser stehende Wellen, die durch eine teilweise Auskopplung das Gehäuse in Form von Laserpulsen verlassen. Je nach Bauart werden zum Beispiel teildurchlässige oder rotierende Spiegel zur Auskopplung verwendet.

###### Kohärent

Laserlicht ist kohärent, was in der Optik einen zeitlichen oder räumlichen Zusammenhang von Wellen bezeichnet, durch die es zu Interferenz kommen kann.

###### Divergent

Im Laser erzeugtes Licht ist divergent, das heißt, der Durchmesser des Laserstrahls weitet sich relativ zu seiner Ausbreitungsgeschwindigkeit auf. Die Intensität des idealen Laserstrahls nimmt vom Zentrum der Strahlenfläche in Form einer Gaußkurve ab.

###### Monochromatisch

Es entsteht ein monochromatisches Licht, genau 1 Wellenlänge. Die Wellenlänge des Lichts ist dabei abhängig vom verwendeten nach aktivem Material und kann auch als Spektrum auftreten. Durch die Kombination von optischen Eigenschaften, können auch mehrere Wellenlängen im Laser erzeugt werden.

#### Messen von Entfernungen

Laserscanner werden zur Messung von Entfernungen zwischen Sensor und Umgebung verwendet. Hauptsächlich unterscheidet man zwischen der Messung der Signallaufzeit, der Phasenverschiebung oder Triangulation. Durch die Auswertung der Intensität der reflektierten Laserstrahlen, können Aussagen über das Material und den Aggregatzustand des gemessenen Hindernisses gemacht werden.

##### Varianten der Entfernungsmessung

Die Bestimmung von Entfernungen durch Messung der Signallaufzeit entspricht am meisten dem Namensgeber \gls{RaDAR}. Mit der Auskopplung des Laserstrahls wird am Laser eine Zeitmessung gestartet. Trifft der Laserstrahl auf ein Hindernis, so wird er teilweise vom Hindernis absorbiert, transmittiert und reflektiert.^[Wie stark ein Hindernis die Laserstrahlung absorbiert, ist abhängig von der Beschaffenheit der Hindernisse, dem Winkel zwischen auftreffendem Laserstrahl und Hindernis sowie der Wellenlänge der Laserstrahlung.]

###### Messung der Signallaufzeit

Durch Differenzbildung von Austritts- und Eintrittszeitpunkt des Laserstrahls wird gemäß (@eq:laufzeit) die Laufzeit bestimmt.

$$ t_{Laufzeit} = t_{Eintritt} - t_{Austritt} $$ {#eq:laufzeit}

Da die gemessene Laufzeit den Hin- und Rückweg bezeichnet, hat der Laserstrahl die doppelte Wegstrecke zurückgelegt. Mit der Ausbreitungsgeschwindigkeit von Licht $c$ wird die halbierte Laufzeit gemäß (@eq:distanzmessung) multipliziert.

$$ d = \frac{t_{Laufzeit}}{2} * c $$ {#eq:distanzmessung}

Die erhaltene Wegstrecke ist die Entfernung zwischen dem \gls{LiDAR}-Sensor und dem Hindernis.

###### Messung der Phasenverschiebung

Die Ausbreitungsgeschwindigkeit von Licht ist abhängig vom Medium indem es sich bewegt. Durch den Zusammenhang zwischen Lichtgeschwindigkeit $c$ und Wellenlänge $\lambda$ kann gemäß {@eq:c_zu_wellenlaenge_und_frequenz} die Frequenz berechnet werden.

$$ c = \lambda * f $$ {#eq:c_zu_wellenlaenge_und_frequenz}

Die Frequenz $f$ ist dabei gemäß {@eq:omega_zu_frequenz} direkt in die Kreisfrequenz $\omega$ umformbar. Durch Bildung des Verhältnisses zwischen der gemessenen Phasenverschiebung $\delta$ und der konstruktionsbedingten Kreisfrequenz $\omega$ kann gemäß {@eq:phasenverschiebung} die Signallaufzeit des Laserstrahls berechnet werden.

$$ \omega = 2 * \pi * f $$ {#eq:omega_zu_frequenz}

$$ t_{Laufzeit} = \frac{\delta}{\omega} $$ {#eq:phasenverschiebung}

###### Messung durch Triangulation

Die Triangulation bezeichnet die Berechnung einer Distanz durch Verhältnisbildung von bekannten Abständen. Bei \gls{LiDAR}-Sensoren ist der Abstand zwischen Laserquelle und Detektor, sowie eine relative Position der Reflexion des Laserstrahls auf dem Sensor bei einer bestimmten Distanz der Reflexionsfläche bekannt.

Gemäß {@eq:triangulation} wird das Verhältnis 

$$ d = \frac{\tan{\alpha}*\tan{\delta}}{\tan{\alpha}+\tan{\delta}} $$ {#eq:triangulation}

##### Einflüsse der Messumgebung

Die Messung von Entfernungen mit Laserlicht unterliegt verschiedenen Umwelteinflüssen. Ob eine Messung verwertbar ist, ist abhängig:

- von der Oberfläche und Material des zu detektierenden Hindernisses,
- der Position des \gls{LiDAR} (stationär oder bewegt),
- Die Entfernung zum Hindernis.

###### Reflexion

Reflexion von Licht bezeichnet das Zurückstrahlen auf Objekten.

Je nach Beschaffenheit der Hindernisse, kann es zu Mehrfachreflektionen (Echos) kommen. Abbildung \ref{fig:} zeigt eine Umgebung mit einem Haus, einem Baum und einem \gls{LiDAR}. Der ausgesandte Laserstrahl wird teilweise am ersten Hindernis reflektiert und transmittiert. Der transmittierte Laserstrahl wird anschließend an einem weiteren Hindernis reflektiert und trifft zeitlich verzögert zum ersten Echo am \gls{LiDAR} auf.

###### Transmission

Transmission bezeichnet die Durchlässigkeit eines Mediums.

Je nach verwendetem aktiven Material im Laser kann Laserlicht unterschiedlicher Wellenlänge erzeugt werden. Ob ein Laserstrahl an bestimmten Objekten transmittiert, absorbiert oder reflektiert wird, ist unter anderem von der Wellenlänge des Laserlichts abhängig. Hindernisse aus Wasser und Glas transmittieren grünes Laserlicht und beugen es. Laserlicht mit infraroter Wellenlänge wird hingegen reflektiert.

###### Absorption

Absorption bezeichnet das Aufnehmen von Teilchen durch einen absorbierenden Stoff.

###### Messung in Bewegung

\gls{LiDAR}-Sensoren übertragen ihre Messwerte meist in Datenpaketen. Diese Datenpakete bestehen aus zusammengefassten Messreihen, denen ein Zeitstempel zugeordnet wird. Wird der \gls{LiDAR} während seiner Messung bewegt, müssen die Zeitstempel auf die einzelnen Messungen interpoliert werden, da sonst die Verortung der Datenpunkte fehlerhaft ist.

### Messung der inertialen Bewegung und globalen Position

Lage und Position im 3-dimensionalen Raum werden als (\gls{6DoF}) bezeichnet, wobei die 6 Freiheitsgrade in 3 translatorische und 3 rotatorische Freiheitsgrade unterteilt werden. Die translatorischen Freiheitsgrade definieren die Position in $X$-, $Y$-, und $Z$-Achse in einem Koordinatensystem. Die rotatorischen Freiheitsgrade bestimmen die Lage an dieser Position durch Rotationen um die Koordinatenachsen. Gemäß @tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300 werden die 3 Eulerschen Winkel $\Phi$ (Phi), $\Theta$ (Theta) und $\Psi$ (Psi) verwendet.

Table: Bezeichnung der Winkel gemäß DIN 9300 / ISO 1151-2:1985. {#tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300}

| Winkel   | Bezeichnung | Rotationsachse |
| :-----   | :-------    | :-----:        |
| $\Phi$   | Gierwinkel  | $Z$            |
| $\Theta$ | Nickwinkel  | $Y$            |
| $\Psi$   | Rollwinkel  | $X$            |

#### Bestimmung von Lage und Ausrichtung durch Inertiale Messeinheiten

##### Gyros und Kreisel

##### doppelte Integration zur Lagebestimmung

#### Globale Positionsbestimmung durch Satellitensysteme

##### Funktionsweise

##### Betrachtung der Messfehler

## Datenstrukturen

Datenstrukturen dienen der geordneten Speicherung von einzelnen zusammengehörigen Daten in einer Struktur. Für die vorliegende Arbeit werden Datenstrukturen für Punkte, Punktwolken und Suchbäumen verwendet, die im Folgenden erläutert werden.

### Punkte

Die Messungen der \gls{LiDAR}-Scanner werden von sphärischen Koordinaten ($d$, $\phi$, $\theta$) in kartesische Koordinaten ($x$, $y$, $z$) transformiert und in der Datenstruktur von Punkten gespeichert. Zusätzlich werden drei Werte zur Speicherung der Koordinaten des Normalenvektors angelegt. Initial sind diese Werte auf $0$ gesetzt, da eine Bestimmung des Normalenvektors erst durch die Kenntnis der umgebenden Punkte möglich ist.

### Punktwolken
### Suchbäume
# Relative extrinsische Kalibrierung von bildgebenden Umweltsensoren
## Forschungsstand

Zum diesem Zeitpunkt ist nur die Arbeit von @Levinson2011 für eine ungeführte extrinsische Kalibrierung von \gls{LiDAR} bekannt. Er beschreibt eine intrinsische sowie eine extrinsische Kalibrierung für ein autonomes Fahrzeug, wobei die präsentierte Lösung auf der Auswertung der einzelnen Laserstrahlen basiert. Er setzt voraus, dass die Echos benachbarter Laserstrahlen auf das gleiche Hindernis in der realen Welt treffen. Bei höheren Fahrzeuggeschwindigkeiten und dynamischeren Bewegungen, scheitert das vorgestellte Verfahren. Des Weiteren ist diese Art der extrinisischen Kalibrierung stark auf den verwendeten Laserscanner zugeschnitten und nicht allgemein anwendbar.

Des Weiteren ist in der Literatur der \gls{SLAM}-Algorithmus bekannt. 

Bisher wurde die extrinsische Kalibrierung von Laserscannern zu \glspl{IMU} anhand fest definierter "Features"^[Features bezeichnet eindeutig erkennbare und unterscheidbare Merkmale in aufgenommenen Bildern.] unter anderem durch @Talaya2004 vorgenommen. Dabei wurden Häuserwände vermessen, deren \gls{GPS}-Positionen bestimmt und mit reflektierenden Materialien beklebt. Anschließend wurden die unterschiedlichen Intensitäten der Laserreflektionen mit den \gls{GPS}-Positionen verglichen, wodurch die Montagepose des Laserscanners bestimmt werden konnte. Das Verfahren basiert auf der Erkennung von planaren Features. Für den Fall, dass keine planaren Flächen zur Verfügung stehen, präsentiert @Chan2015 einen Ansatz, der zylinderförmige Features aus Laserscans zur Kalibrierung verwendet. Es wurden verschiedene Ausrichtungen der Zylinder und unterschiedliche Montagepositionen des Laserscanners untersucht. Das Ergebnis waren einige erfolgreiche Positionsbestimmungen, jedoch auch der Fakt, dass die Verwendung mehrerer unterschiedlich ausgerichteter Zylinder während der Messung zur Fehlidentifikation führten.

Natürliche Umgebungen weisen kaum planare oder zylinderförmige Formen auf, sodass diese Ansätze nur in urbanem Gelände Anwendung finden. @Sheehan2011 identifiziert Scannerparameter anhand von einem Maß der Vielfältigkeit von Punktwolken (Rényi Quadratic Entropy). Ihr Hauptaugenmerk liegt dabei auf der Synchronisation mehrerer Laserscanner zueinander um detailreiche Umgebungsscans zu generieren. Des Weiteren befinden sich die Scanner zwar in einer rotatorischen Bewegung jedoch translatorisch in einem stationären Zustand.

@Davison2007 präsentieren einen \gls{SLAM} Ansatz um mehrere Kamerabilder zu einer zwar spärlichen aber nachhaltigen Landkarte zusammenzufügen. Sie verwenden dafür ein probabilistisches Feature-basiertes Karten- und ein allgemeines Bewegungsmodell einer Kamera. Informationen über die Entfernungen wurden durch die Features definiert. Einen Ansatz zur Generierung von 3D-Landkarten mit Entfernungsinformationen bietet @May2008. Der Ansatz verwendetet \gls{ToF}-Kameras und einen Roboter, der für jede Aufnahme stoppt, wodurch stabile Punktwolken generiert werden können. Alle vorgestellten Ansätze setzen eine genaue Kalibrierung zwischen bildgebenden Sensor und posegebenden Sensor voraus. Die Sensordaten werden fusioniert um das Endergebnis zu verbessern. Durch eine ungenau Kalibrierung werden die Ergebnisse stark verschlechtert oder unbrauchbar.

## Ausgangssituation

## Ansatz zur Kalibrierung

Für die Kalibrierung der Sensoren werden folgende Anforderungen definiert:

- die Umgebung wird als unveränderlich und starr angenommen,
- die zu vermessende Bewegung muss größer als die größte Messungenauigkeit des Systems sein.

### Im Sensorkoordinatensystem

#### Ohne Bewegungskorrektur

\ref{fig:kalibrierung_im_sensorkoordinatensystem} zeigt die Kalibrierung im Sensorkoordinaten

![Kalibrierung im Sensorkoordinatensystem](Images/kalibrierungImSC.pdf) {#fig:kalibrierung_im_sensorkoordinatensystem}

#### Mit Bewegungskorrektur

![Kalibrierung im Sensorkoordinatensystem mit Bewegungskorrektur](Images/kalibrierungImSCmitKorr.pdf) {#fig:kalibrierung_im_sensorkoordinatensystem_mit_korr}

### Im Weltkoordinatensystem

#### Ohne Bewegungskorrektur

![Kalibrierung im Weltkoordinatensystem](Images/kalibrierungImWC.pdf) {#fig:kalibrierung_im_weltkoordinatensystem}

#### Mit Bewegungskorrektur

![Kalibrierung im Weltkoordinatensystem mit Bewegungskorrektur](Images/kalibrierungImWCmitKorr.pdf) {#fig:kalibrierung_im_weltkoordinatensystem_mit_korr}


## Bewegungsextraktion aus aufeinanderfolgenden Punktwolken

\gls{LiDAR}-Sensoren liefern Entfernungsmessungen. Je nach Konstruktion werden die Laserstrahlen dabei abgelenkt, sodass die Messungen verschiedenen Winkeln zugeordnet werden können. 

Punktwolken sind komplexe Datentypen, die aus einzelnen Punkten bestehen. Diese Punkte repräsentieren 

Registrierung von Punktwolken bezeichnet das Ausrichten zueinander. Auf Grund von Messungenauigkeiten der bildgebenden Sensoren

### Filterung der Daten

#### Reichweite des Sensors anpassen

PassThrough Filter

#### Downampling der Punktwolken

##### Voxel-Grids

Jedes belegte Voxel ist durch den Schwerpunkt der Punkte in einem festgelegten Bereich approximiert. 

##### Kovariantes Downsampling

#### Entfernen von Messfehlern

#### Abschätzung der Normalen

### Extraktion von Features

Features oder Merkmale sind räumliche Eigenschaften von Punkten.

#### Bestimmung von Schlüsselpunkten (Keypoints)

Punkte, die in irgendeiner Weise als relevant identifiziert werden, bezeichnet man als Schlüsselpunkte. Sie besitzen dabei folgende Eigenschaften:

- Sparseness bedeutet, dass nur eine kleine Auswahl an Punkten aus der Gesamtmenge in Frage kommen.
- Repeatability heißt, dass die identifizierten Punkte auch in ähnlichen Punktwolken an der entsprechenden Position zu finden sein sollten.
- Distinctiveness bezeichnet die Situation, wenn die Umgebung rund um den Schlüsselpunkt eine eindeutige Form oder Erscheinung aufweist

Durch die Bestimmung von Schlüsselpunkten, kann der Berechnungsaufwand von Features im Vorhinein minimiert werden, da der Suchraum eingeschränkt wird. Ebenfalls wird somit verhindert, dass beim späteren Matching Nicht-Schlüsselpunkte Fehler verursachen.

#### SIFT

#### (Fast) Point-Feature-Histogramm

### Registrierung von Punktwolken

#### Abschätzung von Korrespondierenden Punkten

#### Verwerfen von Korrespondenzen

#### Abschätzung der Transformation

#### Vorgabe einer initialen Ausrichtung

## Implementierung der optimierten Lösung
### Auswahl von Schlüsselszenen
### Verwerfung von ungeeigneten Datensätzen
### Bestimmung neuer Startparameter
# Validierung

Zur Validierung der Kalibrierlösung wurden zwei Experimente durchgeführt. Das erste Experiment dient zur Bestimmung des "Common Ground" anhand eines konstruierten und vermessenen Aufbaus. Das zweite Experiment dient der Erprobung an einem Flugversuch eines automatisierten Hubschraubers. Im Folgenden werden beide Experimente bezüglich ihres Aufbaus, des Ablaufs und den jeweiligen Resultaten erläutert.

## Einsatzgebiet

Das Einsatzgebiet

## Verwendete Sensoren

**Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?**

### Der Laserscanner

Als Laserscanner kommt der Velodyne HDL-32e (im Folgenden als Velodyne bezeichnet) zum Einsatz. Der Sichtbereich des Velodyne beträgt 360° um seine Y-Achse. Durch 32 vertikal angeordnete Laserquellen beträgt der Sichtbereich in der ZX-Ebene zwischen +10° und -30°. Der Messbereich liegt bei 1m bis 100m mit einer Standardabweichung von +/- 2cm bei 25m. Die horizontale Auflösung ist abhängig von der, vom Anwender eingestellten, Bildrate (Framerate). Die Framerate kann vom Benutzer zwischen 5Hz und 20Hz gewählt werden. Für diesen Versuch wurde die Framerate auf 10Hz eingestellt.

![Schematische Darstellung des Velodyne HDL-32e mit Koordinatensystem](Images/velodyne_view.png) {#fig:schematische_darstellung_des_velodyne_hdl-32e_mit_koordinatensystem}

Der Laserscanner misst den Rotationswinkel $\Theta$, die Distanz zum Objekt, dem Intensitätswert des jeweiligen Hits (ein Hit bezeichnet den Auftreffpunkt des Laserstrahls auf einem Objekt) und einem Zeitstempel. Die aufgenommenen Sensordaten werden per \gls{UDP} an den Flugrechner weitergeleitet und dort in Sensorkoordinaten transformiert.

### Die inertiale Messeinheit

Als inertiale Messeinheit wird die iMar \gls{IMU} iTraceRT-F400-Q verwendet. Die \gls{IMU} bietet eine "Deep-Coupled" Sensorumgebung aus \gls{INS} und \gls{GNSS}. Das \gls{INS} wird durch Fiber-Optische Gyroskope realisiert; das \gls{GNSS} unterstützt \gls{GPS}, \gls{GLONASS} sowie \gls{BeiDou} Satelliten.

## Versuch - "Common Ground"

### Aufbau

Der Versuch "Common Ground" dient der Bestimmung der Genauigkeit der Kalibrierungslösung. Der Aufbau besteht aus den zur Kalibrierung benötigten Geräten gemäß Tabelle {@tbl:Common-Ground-Geraete}, die auf einer gemeinsamen Trägerplattform befestigt sind.

Table: Geräteübersicht. {#tbl:Common-Ground-Geraete}

| Anzahl | Gerät                                                          |
| :---   | :--                                                            |
| 1      | Laserscanner Velodyne HDL-32e                                  |
| 1      | iMAR IMU iTrace RT-F400Q                                       |
| 1      | Spannungsversorgungsgerät (\gls{DLR}-Eigenbau)                 |
| 1      | Flugcomputer zur Aufnahme der Sensordaten (\gls{DLR}-Eigenbau) |
| 2      | Novatel \gls{GPS}-Antennen                                     |

Der Aufbau wurde bezüglich der Winkel und Abstände gemäß {@tbl:abstaende_im_aufbau} und {@tbl:winkel_im_aufbau} kalibriert und für den Versuch in einem Forschungsfahrzeug des \gls{DLR} verbaut.

Table: Abstände zwischen den Sensoren auf der Trägerplattform. {#tbl:abstaende_im_aufbau}

| Achse | Abstand relativ zur IMU in [mm] |
| :---: | :---                            |
| **X** |                                 |
| **Y** |                                 |
| **Z** |                                 |

Table: Winkel zwischen den Sensoren auf der Trägerplattform. {#tbl:winkel_im_aufbau}

| Achse | Rotationswinkel relativ zur IMU in [°] |
| :---: | :---                                   |
| **X** |                                        |
| **Y** |                                        |
| **Z** |                                        |

Die inertiale Messeinheit benötigt zur Bestimmung des Headings mindestens eine \gls{GPS}-Antenne und deren Montageposition relativ zur Position der \gls{IMU}.

Table: Montageabstände zwischen den GPS-Antennen und der IMU. {#tbl:montageabstaende_zwischen_den_gps-antennen_und_der_imu}

| Achse | Antenne 1 in [mm] | Antenne 2 in [mm] |
| :-:   | :----:            | :------:          |
| **X** | 44.5              | -114.0            |
| **Y** | 11.0              | 0.0               |
| **Z** | -2.0              | -3.0              |

### Ablauf

### Ergebnisse

## Versuch - "In-Flight"

### Aufbau

Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?

### Ablauf

Während eines Experimentalfluges werden in regelmäßigen Abständen Bewegungs- und Laserdaten aufgenommen. Die Abstände richten sich nach den jeweiligen Fähigkeiten der Sensoren.

### Ergebnisse

## Ergebnisanalyse

# Fazit und Ausblick

Was wurde gemacht?
Was war das Resultat?
Was ergeben sich für Folgeaufgaben?

\begin{chapquote}{Doc Brown, \textit{Back to the Future}}
``Roads? Where we're going, we don't need roads.''
\end{chapquote}

Möchten wir uns heute in ein anderes Land begeben, beruflich oder privat verreisen, stehen uns verschiedene Transportmittel zur Verfügung. Sie unterscheiden sich in der verfügbaren Kapazität, Reichweite, Geschwindigkeit und den Reisekosten. Autos, Züge und Busse sind ideal, um zügig und ohne Umschweife mehrere 100 km zurückzulegen. Das Schiff bietet den schwergewichtigen und zeitlosen Transport, durch Kreuzfahrten wird es zur Attraktion selbst. Das Flugzeug bietet den schnellen Transport über mehrere 1000 km.

Die Raumfahrt ist bisher das kostspieligste Transportmittel und für den zivilen Personentransport unerschlossen. Private Firmen wie SpaceX sind auf dem Vormarsch, die Raumfahrt rentabel zu machen. Durch Experimente zur Rückgewinnung von Antriebssystemen sollen die Kosten gesenkt und die rasche Wiederverwendung ermöglicht werden.

Nach @Lipps2005 ist die Zahl der zurückgelegten Kilometer aller Transportwege in Westdeutschland von 1982 bis 2002 um 40% gestiegen. Der Bedarf nach weltweiter Mobilität wächst stetig. Der Weg bis zum Ziel kann je nach verwendetem Transportmittel unterschiedlich genutzt werden. Durch Fahrgemeinschaften oder Passagiertransporte können die Mitreisenden die Reisezeit individuell nutzen. Die Fahrzeugführer sind dabei komplett in den Reiseverkehr involviert und werden bereits heute durch unterschiedliche Assistenzsysteme unterstützt. Im Kraftfahrzeugbereich zählen zum Beispiel Geschwindigkeitsregelung, Spur- und Abstandsassistenten sowie Navigationssysteme bereits zum Repertoire der Werksausstattung. In der Luftfahrt halten seit einigen Jahren Autopiloten sowie Systeme zur automatisierten Landung Einzug. Im Bereich der Schifffahrt werden Containerschiffe bereits vollautomatisiert durch eine minimale Besatzung gefahren.

Der Gütertransport befindet sich im Wandel zur Automatisierung. So forschen Versandunternehmen wie Amazon bereits an selbstfliegenden Drohnen zur individuellen Paketzustellung. Ebenfalls kommen automatisierte Systeme zur Überwachung bei verschiedenen Polizeibehörden zum Einsatz.

Die Automatisierung verfolgt dabei die Ziele, "dirty, dangerous and demanding" Aufgaben vom Menschen zu übernehmen und das Risiko von Unfällen und Fehlern zu minimieren. Zusätzlich senken effizientere Systeme den Verbrauch von Ressourcen und verringern die Verschmutzung unserer Umwelt.

In den kommenden Jahren wird sich meiner Meinung nach das Transportwesen insofern weiterentwickeln, dass uns Fahrzeuge auf unseren Reisen selbstständig transportieren werden und dabei die dritte Dimension, den Luftraum, nutzen. Dadurch können weitere Strecken in kürzerer Zeit zurückgelegt werden. Die bisherige Unterteilung des Transports von Wasser, Land und Luft wird sich in Slow (Low) und Fast (High) weiterentwickeln.

Durch diesen Fortschritt und die daran geknüpften Anforderungen müssen die Assistenzsysteme grundlegende Aufgaben erfüllen:

- die Umwelt wahrnehmen und klassifizieren;
- sich selbst in dieser Umgebung lokalisieren;
- zielführende Entscheidungen selbstständig treffen.

\chapter*{Literaturverzeichnis}
\addcontentsline{toc}{chapter}{Literaturverzeichnis}