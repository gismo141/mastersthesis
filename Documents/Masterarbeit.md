# Einleitung

\begin{chapquote}{Doc Brown, \textit{Back to the Future}}
``Roads? Where we're going, we don't need roads.''
\end{chapquote}

Möchten wir uns heute in ein anderes Land begeben, beruflich oder privat verreisen, stehen uns verschiedene Transportmittel zur Verfügung. Sie unterscheiden sich in der verfügbaren Kapazität, Reichweite, Geschwindigkeit und den Reisekosten. Autos, Züge und Busse sind ideal, um zügig und ohne Umschweife mehrere 100 km zurückzulegen. Das Schiff bietet den schwergewichtigen und zeitlosen Transport, durch Kreuzfahrten wird es zur Attraktion selbst. Das Flugzeug bietet den schnellen Transport über mehrere 1000 km.

Die Raumfahrt ist bisher das kostspieligste Transportmittel und für den zivilen Personentransport unerschlossen. Private Firmen wie SpaceX sind auf dem Vormarsch, die Raumfahrt rentabel zu machen. Durch Experimente zur Rückgewinnung von Antriebssystemen sollen die Kosten gesenkt und die rasche Wiederverwendung ermöglicht werden.

Nach @Lipps2005 ist die Zahl der zurückgelegten Kilometer aller Transportwege in Westdeutschland von 1982 bis 2002 um 40% gestiegen. Der Bedarf nach weltweiter Mobilität wächst stetig. Der Weg bis zum Ziel kann je nach verwendetem Transportmittel unterschiedlich genutzt werden. Durch Fahrgemeinschaften oder Passagiertransporte können die Mitreisenden die Reisezeit individuell nutzen. Die Fahrzeugführer sind dabei komplett in den Reiseverkehr involviert und werden bereits heute durch unterschiedliche Assistenzsysteme unterstützt. Im Kraftfahrzeugbereich zählen zum Beispiel Geschwindigkeitsregelung, Spur- und Abstandsassistenten sowie Navigationssysteme bereits zum Repertoire der Werksausstattung. In der Luftfahrt halten seit einigen Jahren Autopiloten sowie Systeme zur automatisierten Landung Einzug. Im Bereich der Schifffahrt werden Containerschiffe bereits vollautomatisiert durch eine minimale Besatzung gefahren.

Der Gütertransport befindet sich im Wandel zur Automatisierung. So forschen Versandunternehmen wie Amazon bereits an selbst fliegenden Drohnen zur individuellen Paketzustellung. Ebenfalls kommen automatisierte Systeme zur Überwachung bei verschiedenen Polizeibehörden zum Einsatz.

Die Automatisierung verfolgt dabei die Ziele, "dirty, dangerous and demanding" Aufgaben vom Menschen zu übernehmen und das Risiko von Unfällen und Fehlern zu minimieren. Zusätzlich senken effizientere Systeme  den Verbrauch von Ressourcen und verringern die Verschmutzung unserer Umwelt.

In den kommenden Jahren wird sich meiner Meinung nach das Transportwesen insofern weiterentwickeln, dass uns Fahrzeuge auf unseren Reisen selbstständig transportieren werden und dabei die dritte Dimension, den Luftraum, nutzen. Dadurch können weitere Strecken in kürzerer Zeit zurückgelegt werden. Die bisherige Unterteilung des Transports von Wasser, Land und Luft wird sich in Slow (Low) und Fast (High) weiterentwickeln.

Durch diesen Fortschritt und die daran geknüpften Anforderungen müssen die Assistenzsysteme grundlegende Aufgaben erfüllen:

- die Umwelt wahrnehmen und klassifizieren;
- sich selbst in dieser Umgebung lokalisieren;
- zielführende Entscheidungen selbstständig treffen.

Für diese Arbeit wird folgende Forschungsfrage formuliert: "Ist es möglich, bildgebende Sensoren anhand von visuellen Merkmalen relativ zu gleichzeitig aufgezeichneten Bewegungsdaten zu kalibrieren?" Der präsentierte Ansatz zur Kalibrierung von Laserscannern zu Navigationsdaten soll eine Identifikation des Systems mit seiner Umwelt ermöglichen und das System befähigen, seine Bewegung im Raum mit den Sensordaten zu verknüpfen.

Dazu werden Laserdaten während der Bewegung sequentiell mit einem \gls{ICP}-Algorithmus registriert. Durch die Registrierung werden die Laserscans anhand von Gemeinsamkeiten aneinander angeglichen und die Unterschiede in Position und Lage in Form einer mehrdimensionalen Transformation berechnet. Parallel zu den Scans werden Navigationsdaten mittels einer \gls{IMU} und einem \gls{GPS} ausgezeichnet. Aus diesen Daten wird eine Bewegungstransformation bestimmt und mit der \gls{ICP}-Transformation verglichen. Durch die Differenz dieser Transformationen wird die Montageposition vom Laserscanner zur \gls{IMU} berechnet.

# Extrinsische Kalibrierung von Laserscannern zu Inertialen Messeinheiten

Das \glspl{DLR} erforscht am Institut für Luftfahrtsysteme in der Abteilung Unbemannte Luftfahrzeuge die automatisierte Bewegung von \gls{UA} in unbekanntem Luftraum. Anforderungen an das automatisierte System sind die Wahrnehmung der Umwelt, die Bestimmung der eigenen Position und Lage (Pose) im Raum und entsprechende Entscheidungen für die Erfüllung einer bestimmten Mission ableiten. Die Grundvoraussetzung zur Umwelt- und Selbstwahrnehmung ist eine gemeinsame Datenbasis der Sensordaten. Dadurch können die verschiedenen Sensorwerte zueinander in Verbindung gebracht werden. Eine Fusion der Daten wird erschwert wenn:

- je nach Flugauftrag variable Grundkonfigurationen (verschiedene Sensoren) verwendet werden,
- je nach Umgebung unterschiedliche Trägersysteme eingesetzt werden (Größen- oder Gewichtsbestimmungen)
- Beladungszustände variieren, die eine Austarierung der Sensoren erfordern.

Einige dieser Probleme können gelöst werden, wenn zu jedem Experiment der Aufbau der Sensorplattform vermessen oder durch eine Konstruktionszeichnungen festgelegt wird. Im Anschluss müssen die erhaltenen Daten in die Sensorfusion eingepflegt und eventuell manuell angepasst werden.

Dieses Vorgehen ist aufwendig, fehleranfällig und je nach \gls{UA} schwer umsetzbar. Der in dieser Arbeit vorgestellte Ansatz ermöglicht die Bestimmung der Montageparameter von Laserscannern relativ zu einem Navigationssystem (\gls{IMU} und \gls{GPS}). Die grundlegende Idee besteht darin, Unterschiede in sequentiellen Laserscans mit der gemessenen Bewegung des \gls{UA} zu vergleichen. Für diese Lösung wird eine während der Kalibrierung statische Konfiguration vorausgesetzt. Das bedeutet, dass Laserscanner und die Navigationssensoren zueinander statisch, auf der gleichen Trägerplattform befestigt sind.

Die folgenden Kapitel sind in die Analyse der Anforderungen zur Umwelt- und Selbstwahrnehmung gegliedert, in denen die jeweiligen technischen sowie physikalische Grundlagen zu den Sensoren erläutert werden. Im Anschluss wird der Ansatz zur relativen extrinsischen Kalibrierung präsentiert. Anschließend wird der im \gls{DIP}-Framework^[Das \gls{DIP}-Framework dient seit 2004 als Plattform zur Evaluation digitaler Bildverarbeitungsalgorithmen in der Abteilung \gls{ULF} am \gls{DLR}. Für weitere Informationen zur grundlegenden Idee und den Hintergründen des Frameworks siehe @Guth2004 und @Goormann2004.] als Filter implementierte Algorithmus validiert.

## Wahrnehmung der Umwelt

Umweltwahrnehmung ist für Lebewesen, wie den Menschen, eine überlebenswichtige Fähigkeit. Durch unsere Sinne erkennen wir unser Umfeld, können die Umgebung klassifizieren und bedrohliche Situationen erkennen. Bedrohlich bezeichnet dabei Situationen, in denen entweder wir, unsere Mitmenschen oder Ziele eines Auftrags gefährdet sind. Ein großer Bestandteil unserer Wahrnehmung ist visuell und erfolgt durch unsere Augen.

Automatisierte Systeme verwenden zur visuellen Wahrnehmung sogenannte bildgebende Sensoren. Diese Sensoren erstellen in zeitlichen Abständen ein Bild für einen physikalisch begrenzten Blickbereich (engl. field of view). Dabei wird aus Messgrößen eines realen Objektes ein Abbild erzeugt, wobei die Messgröße oder eine daraus abgeleitete Information ortsaufgelöst und über Helligkeitswerte oder Farben kodiert visualisiert wird. \gls{LRF} sind Sensoren, die zur Bestimmung von Entfernungen verwendet werden. Einsatzgebiete sind unter Anderem topographische Geländeaufnahmen (Kartographie) [@Lindenberger1993], Detektion und Tracking von Hindernissen [@Mendes2004] und Identifikation atmosphärischer Eigenschaften [@Wulfmeyer1998; @Browell1998].

### Exemplarischer Aufbau und Funktionsweise eines LRFs

Gemäß @Zabler2006 werden bildgebende Sensoren in flashende und scannende Systeme unterteilt. Ein flashendes System vermisst, basierend auf einem Triggersignal, einmalig das komplette Blickfeld des Sensors. Ein scannendes System generiert kontinuierlich aufeinanderfolgende Messungen im Blickfeld. \gls{LRF} können sowohl als flashendes als auch als scannendes System gebaut werden. 

Ein \gls{LRF} besteht gemäß Abbildung @fig:aufbau_LRF aus einer Laserquelle, einem Spiegel und einem Gehäuse. Die Laserquelle erzeugt durch "Pulsen" von Ladungsträgern eine Strahlung mit konstanter Wellenlänge. Die energiereiche Strahlung wird anschließend gebündelt an einem Spiegel abgelenkt und verlässt das Gehäuse.

<!-- ![Exemplarischer Aufbau eines \gls{LRF} (schematisch)]() #fig:aufbau_LRF -->

Zu diesem Zeitpunkt wird im \gls{LRF} eine Zeitmessung gestartet. Trifft der Laserstrahl auf ein Hindernis, so wird er teilweise vom Hindernis absorbiert und reflektiert.^[Wie stark ein Hindernis die Laserstrahlung absorbiert, ist abhängig von der Beschaffenheit der Hindernisse, dem Auftreffwinkel zwischen Laserstrahl und Hindernis und der Wellenlänge der Laserstrahlung.]

Der reflektierte Laserstrahl wird vom \gls{LRF} detektiert. Durch Differenzbildung von Austritts- und Eintrittszeitpunkt gemäß (@eq:laufzeit) wird die Laufzeit des Laserstrahls bestimmt.

$$ t_{Laufzeit} = t_{Eintritt} - t_{Austritt} $$ {#eq:laufzeit}

Da die gemessene Laufzeit den Hin- und Rückweg bezeichnet, hat der Laserstrahl die doppelte Wegstrecke zurückgelegt. Durch die Annahme einer konstanten Lichtgeschwindigkeit im Vakuum (@eq:lichtgeschwindigkeit) wird die Laufzeit halbiert und mit der Lichtgeschwindigkeit gemäß (@eq:distanzmessung) multipliziert.

$$ c = 299792458 \frac{\text{m}}{\text{s}} $$ {#eq:lichtgeschwindigkeit}

$$ d = \frac{t_{Laufzeit}}{2} * c $$ {#eq:distanzmessung}

Die erhaltene Wegstrecke ist die Entfernung vom \gls{LRF} zum Hindernis.

### Besonderheiten bei der Messung von Laserstrahlung

Die Messung von Laserlicht unterliegt verschiedenen Umwelteinflüssen. Ob eine Messung verwertbar ist, ist abhängig:

- von der Oberfläche des zu detektierenden Hindernisses,
- ob der \gls{LRF} stationär an einem Ort oder im Raum bewegt wird,
- wie weit die Hindernisse vom \gls{LRF} entfernt sind.

#### Mehrfachreflektionen durch unterschiedliche Hindernisdichten

Je nach Beschaffenheit der Hindernisse, kann es zu Mehrfachreflektionen (Echos) kommen. Abbildung \ref{fig:} zeigt eine Beispielumgebung mit einem Haus, einem Baum und einem \gls{LRF}. Der gleiche Laserstrahl wird teilweise am Hindernis reflektiert und durchgelassen. Der durchdrungene Laserstrahl wird anschließend an einem weiteren Hindernis reflektiert und trifft zeitlich verzögert zum ersten Echo am \gls{LRF} auf.

#### Messung in Bewegung

#### Detektion von Hindernissen aus Glas und Wasser

## Wahrnehmung der aktuellen Position und Lage

Lage und Position im 3-dimensionalen Raum werden als (\gls{6DoF}) bezeichnet, wobei die 6 Freiheitsgrade in 3 translatorische und 3 rotatorische Freiheitsgrade unterteilt werden. Die translatorischen Freiheitsgrade definieren die Position in $X$-, $Y$-, und $Z$-Achse in einem Koordinatensystem. Die rotatorischen Freiheitsgrade bestimmen die Lage an dieser Position durch Rotationen um die Koordinatenachsen. Gemäß @tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300 werden die 3 Eulerschen Winkel $\Phi$ (Phi), $\Theta$ (Theta) und $\Psi$ (Psi) verwendet.

Table: Bezeichnung der Winkel gemäß DIN 9300 / ISO 1151-2:1985. {#tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300}

| Winkel   | Bezeichnung | Rotationsachse |
| :-----   | :-------    | :-----:        |
| $\Phi$   | Gierwinkel  | $Z$            |
| $\Theta$ | Nickwinkel  | $Y$            |
| $\Psi$   | Rollwinkel  | $X$            |

### Bestimmung der Position mittels GPS

### Bestimmung der Lage mittels IMU

## Stand der Forschung

Bisher wurde die extrinsische Kalibrierung von Laserscannern zu \glspl{IMU} anhand fest definierter "Features"^[Features bezeichnet eindeutig erkennbare und unterscheidbare Merkmale in aufgenommenen Bildern.] unter anderem durch @Talaya2004 vorgenommen. Dabei wurden Häuserwände vermessen, deren \gls{GPS}-Positionen bestimmt und mit reflektierenden Materialien beklebt. Anschließend wurden die unterschiedlichen Intensitäten der Laserreflektionen mit den \gls{GPS}-Positionen verglichen, wodurch die Montagepose des Laserscanners bestimmt werden konnte. Das Verfahren basiert auf der Erkennung von planaren Features. Für den Fall, dass keine planaren Flächen zur Verfügung stehen, präsentiert @Chan2015 einen Ansatz, der zylinderförmige Features aus Laserscans zur Kalibrierung verwendet. Es wurden verschiedene Ausrichtungen der Zylinder und unterschiedliche Montagepositionen des Laserscanners untersucht. Das Ergebnis waren einige erfolgreiche Positionsbestimmungen, jedoch auch der Fakt, dass die Verwendung mehrerer unterschiedlich ausgerichteter Zylinder während der Messung zur Fehlidentifikation führten.

Natürliche Umgebungen weisen kaum planare oder zylinderförmige Formen auf, sodass diese Ansätze nur in urbanem Gelände Anwendung finden. @Sheehan2011 identifiziert Scannerparameter anhand von einem Maß der Vielfältigkeit von Punktwolken (Rényi Quadratic Entropy). Ihr Hauptaugenmerk liegt dabei auf der Synchronisation mehrerer Laserscanner zueinander um detailreiche Umgebungsscans zu generieren. Des Weiteren befinden sich die Scanner zwar in einer rotatorischen Bewegung jedoch translatorisch in einem stationären Zustand.

@Davison2007 präsentieren einen \gls{SLAM} Ansatz um mehrere Kamerabilder zu einer zwar spärlichen aber nachhaltigen Landkarte zusammenzufügen. Sie verwenden dafür ein probabilistisches Feature-basiertes Karten- und ein allgemeines Bewegungsmodell einer Kamera. Informationen über die Entfernungen wurden durch die Features definiert. Einen Ansatz zur Generierung von 3D-Landkarten mit Entfernungsinformationen bietet @May2008. Der Ansatz verwendetet \gls{ToF}-Kameras und einen Roboter, der für jede Aufnahme stoppt, wodurch stabile Punktwolken generiert werden können. Alle vorgestellten Ansätze setzen eine genaue Kalibrierung zwischen bildgebenden Sensor und posegebenden Sensor voraus. Die Sensordaten werden fusioniert um das Endergebnis zu verbessern. Durch eine ungenau Kalibrierung werden die Ergebnisse stark verschlechtert oder unbrauchbar.

##  Extrinsische Kalibrierung mit Nicht-linearem ICP-Optimierer 

### Möglichkeiten zur Kalibrierung

Für die Kalibrierung der Sensoren werden folgende Anforderungen definiert:

- die Umgebung wird als unveränderlich und starr angenommen,
- die zu vermessende Bewegung muss größer als die größte Messungenauigkeit des Systems sein.

#### Im Sensorkoordinatensystem

##### Ohne Bewegungskorrektur

\ref{fig:kalibrierung_im_sensorkoordinatensystem} zeigt die Kalibrierung im Sensorkoordinaten

![Kalibrierung im Sensorkoordinatensystem](Images/kalibrierungImSC.pdf) {#fig:kalibrierung_im_sensorkoordinatensystem}

##### Mit Bewegungskorrektur

![Kalibrierung im Sensorkoordinatensystem mit Bewegungskorrektur](Images/kalibrierungImSCmitKorr.pdf) {#fig:kalibrierung_im_sensorkoordinatensystem_mit_korr}

#### Im Weltkoordinatensystem

##### Ohne Bewegungskorrektur

![Kalibrierung im Weltkoordinatensystem](Images/kalibrierungImWC.pdf) {#fig:kalibrierung_im_weltkoordinatensystem}

##### Mit Bewegungskorrektur

![Kalibrierung im Weltkoordinatensystem mit Bewegungskorrektur](Images/kalibrierungImWCmitKorr.pdf) {#fig:kalibrierung_im_weltkoordinatensystem_mit_korr}

## Validierung

Zur Validierung der Kalibrierlösung wurden zwei Experimente durchgeführt. Das erste Experiment dient zur Bestimmung des "Common Ground" anhand eines konstruierten und vermessenen Aufbaus. Das zweite Experiment dient der Erprobung an einem Flugversuch eines automatisierten Hubschraubers. Im Folgenden werden beide Experimente bezüglich ihres Aufbaus, des Ablaufs und den jeweiligen Resultaten erläutert.

### Einsatzgebiet

Das Einsatzgebiet 

### "Verwendete Sensoren"

**Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?**

#### Der Laserscanner

Als Laserscanner kommt der Velodyne HDL-32e (im Folgenden als Velodyne bezeichnet) zum Einsatz. Der Sichtbereich des Velodyne beträgt 360° um seine Y-Achse. Durch 32 vertikal angeordnete Laserquellen beträgt der Sichtbereich in der ZX-Ebene zwischen +10° und -30°. Der Messbereich liegt bei 1m bis 100m mit einer Standardabweichung von +/- 2cm bei 25m. Die horizontale Auflösung ist abhängig von der, vom Anwender eingestellten, Bildrate (Framerate). Die Framerate kann vom Benutzer zwischen 5Hz und 20Hz gewählt werden. Für diesen Versuch wurde die Framerate auf 10Hz eingestellt.

![Schematische Darstellung des Velodyne HDL-32e mit Koordinatensystem](Images/velodyne.png) {#fig:schematische_darstellung_des_velodyne_hdl-32e_mit_koordinatensystem}

Der Laserscanner misst den Rotationswinkel $\Theta$, die Distanz zum Objekt, dem Intensitätswert des jeweiligen Hits (ein Hit bezeichnet den Auftreffpunkt des Laserstrahls auf einem Objekt) und einem Zeitstempel. Die aufgenommenen Sensordaten werden per \gls{UDP} an den Flugrechner weitergeleitet und dort in Sensorkoordinaten transformiert.

#### Die inertiale Messeinheit

Als inertiale Messeinheit kommt die iMar \gls{IMU} iTraceRT-F400-Q zum Einsatz. Die \gls{IMU} bietet eine hochgenaue "Deep-Coupled" Sensorumgebung aus \gls{INS} und \gls{GNSS}. Das \gls{INS} wird durch Fiber-Optische Gyroskope realisiert; das \gls{GNSS} unterstützt \gls{GPS}, \gls{GLONASS} sowie \gls{BeiDou} Satelliten.

Table: Montageabstände zwischen den GPS-Antennen und der IMU. {#tbl:montageabstaende_zwischen_den_gps-antennen_und_der_imu}

|       | Antenne 1 in [mm] | Antenne 2 in [mm] |
| :-:   | :----:            | :------:          |
| **X** | 44.5              | -114.0            |
| **Y** | 11.0              | 0.0               |
| **Z** | -2.0              | -3.0              |

### Versuch - "Common Ground"

#### Aufbau

Mit dem Experiment wird die Genauigkeit der Kalibrierungslösung bestimmt. Der Aufbau besteht aus den zur Kalibrierung benötigten Geräten gemäß Tabelle @tbl:Common-Ground-Geraete.

Table: Geräteübersicht. {#tbl:Common-Ground-Geraete}

| Anzahl | Gerät                                                          |
| :---   | :--                                                            |
| 1      | Laserscanner Velodyne HDL-32e                                  |
| 1      | iMAR IMU iTrace RT-F400Q                                       |
| 1      | Spannungsversorgungsgerät (\gls{DLR}-Eigenbau)                 |
| 1      | Flugcomputer zur Aufnahme der Sensordaten (\gls{DLR}-Eigenbau) |
| 2      | Novatel \gls{GPS}-Antennen                                     |

#### Ablauf

Während eines Experimentalfluges werden in regelmäßigen Abständen Bewegungs- und Laserdaten aufgenommen. Die Abstände richten sich nach den jeweiligen Fähigkeiten der Sensoren.

```Bash
./dip/bin/obdip-release-linux64-g++
./artis/bin/itracert-logger-release-linux64-g++
```

#### Ergebnisse

### Versuch - "In-Flight"

#### Aufbau

Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?

#### Ablauf

Während eines Experimentalfluges werden in regelmäßigen Abständen Bewegungs- und Laserdaten aufgenommen. Die Abstände richten sich nach den jeweiligen Fähigkeiten der Sensoren.

#### Ergebnisse

### Gesamtresultat

# Fazit und Ausblick

1. Was wurde gemacht?
2. Was war das Resultat?
3. Was ergeben sich für Folgeaufgaben?

