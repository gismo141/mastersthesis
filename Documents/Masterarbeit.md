# Einleitung

In den letzten Jahren hat das allgemeine Interesse am Autonomen Fahren stark zugenommen. Namhafte Hersteller wie zum Beispiel Audi und BMW bieten bereits hochautomatisierte Fahrzeuge in ihrem Portfolio an, die den Fahrer in alltäglichen Situationen entlasten. Das Fahrzeug kann unter Kontrolle des Fahrers selbstständig einparken oder in Stau-Situationen die Spur, sowie einen geschwindigkeitsabhängigen Sicherheitsabstand zu den vorausfahrenden Fahrzeugen einhalten. Im Notfall können Notbremsungen vom Fahrzeug selbst eingeleitet oder dem Fahrer mögliche Ausweichmanöver mitgeteilt und initiiert werden.

Im Bereich der Luftfahrt werden, ähnlich zum Straßenverkehr, Flugvorgänge automatisiert, um die Piloten von monotonen Aufgaben zu entlasten und die Fehleranfälligkeit zu minimieren. Automatisiert bedeutet dabei, dass bestimmte Funktionen vom Piloten aktiv an das System übergeben werden. Das System arbeitet anschließend anhand von festen Programmen die Aufgaben ab. Anwendungsgebiete sind z.B. das Abfliegen eines Flugplanes im 3-dimensionalen Raum oder ein automatisierter Landeanflug.

Die Abteilung für Flugsysteme beschäftigt sich am \gls{DLR} in Braunschweig mit der Autonomisierung der \gls{UA}. Umweltwahrnehmung, Flugregelung und Flugplanung zählen zu den hauptsächlichen Forschungsbereichen. Das Ziel ist der sichere und autonome Flugbetrieb.

Der Begriff der Autonomie wird in der Wissenschaft unterschiedlich aufgefasst. Für diese Arbeit wird ein System als autonom betrachtet, wenn es seine Aktionen selbstständig plant, ausführt und auf Veränderungen der Umwelt entsprechend reagiert. Wird ein 3-dimensionaler Pfad (im Folgenden als Trajektorie bezeichnet) durch einen Menschen vorgegeben und vom System abgeflogen, so wird dies als hochautomatisiert, aber nicht als autonom, bezeichnet. Plant das System seinen Flugpfad auf Grund seiner Messwerte und Missionsvorgaben ohne Vorgabe eines Menschen, so wird dies als autonom bezeichnet.

Um einem System die Autonomie zu ermöglichen, müssen einige grundlegende Fähigkeiten gegeben sein. Die erste Bedingung an das System ist das selbstständige Planen von Trajektorien. Bekannte Pfadplanungsansätze arbeiten mit Hinderniskarten, in denen die Hindernisse mit verschiedenen Eigenschaften (wie z.B. der Farbe, der Oberflächenstruktur, etc.) vermerkt werden. Durch bildgebende Sensoren, wie Laserscanner und Kameras, können detektierte Hindernisse zu diesen Karten hinzugefügt oder die vermerkten Eigenschaften der Hindernisse verbessert werden.

Damit die von den Sensoren detektierten Hindernisse in die Karten eingetragen werden können, müssen die Sensordaten in ein gemeinsames Koordinatensystem überführt werden. Dafür werden die Sensordaten schrittweise zwischen verschiedenen Koordinatensystemen (Sensor-, Träger- und Weltkoordinatensystemen) transformiert.

Die Transformation der Sensordaten in das globale Koordinatensystem oder in andere Sensorkoordinatensysteme enthält oft unbekannte und variable Parameter. Einerseits ist die genaue Position und Lage (Pose) des Sensors im Gehäuse unbekannt. Andererseits ist die Pose des Sensors auf dem Träger je nach Experiment unterschiedlich und auf Grund platzsparender Konstruktion nur sehr schwer messbar. Dadurch werden die Sensordaten falsch transformiert und die Sensor-Fusion erschwert.

Die in dieser Arbeit präsentierte Lösung ermöglicht die automatische Bestimmung der Montagepose von \gls{LiDAR}-Sensoren relativ zur \gls{IMU}.

Ausgangspunkt für den zu entwerfenden Ansatz sind relative Translationen und Rotationen (\gls{6DoF}) des \gls{LiDAR} zur betrachteten Umwelt. Diese werden mit Hilfe des \gls{ICP} Algorithmus aus sukzessiven Aufnahmen bestimmt. Über den Abgleich der berechneten Transformation, der gemessenen Bewegung der \gls{IMU} und dem Einsatz einer nicht linearen Optimierung, wird anschließend die \gls{6DoF} Transformation zwischen den beiden Sensoren bestimmt.

# Grundlagen

## Die verwendeten Koordinatensysteme

Autonome Systeme benötigen verschiedene Sensoren, um ihre Umwelt zu vermessen, zu klassifizieren und Entscheidungen zu treffen. Bevor die verschiedenen Daten in einen Zusammenhang gebracht werden können, müssen sie auf eine gemeinsame Datenbasis fusioniert werden.

Jedes aufgenommene Datum eines Sensors befindet sich in einem Sensorkoordinatensystem. Der Ursprung des Koordinatensystems ist der Nullpunkt des Sensors, den jeder Sensorhersteller unterschiedlich definiert.  

Die verschiedenen Sensoren sind auf einem Sensorträger befestigt. Der Ursprung des sogenannten Trägerkoordinatensystems ist meist der Ursprung der \gls{IMU}. Alle Sensorposen werden relativ zur \gls{IMU}-Pose ausgerichtet.

Des Weiteren befindet sich das autonome System zu einem bestimmten Zeitpunkt in einer Lage und einer Position in seiner Umgebung. Dessen Bezugsort ist der Ursprung für das Weltkoordinatensystem.

### Das Sensorkoordinatensystem

Das Sensorkoordinatensystem ist je nach Sensor und Hersteller unterschiedlich definiert. Im Folgenden werden die Koordinatensysteme erläutert, die in dieser Arbeit hauptsächlich Anwendung finden.

### Das Trägerkoordinatensystem

Das Trägerkoordinatensystem beschreibt die Position und Lage der verschiedenen Sensoren zum Bezugspunkt des Trägers. Als Träger wird meist die Konstruktion bezeichnet, auf dem die Sensoren befestigt sind. Da in vielen Anwendungen auch Parameter gewünscht sind, die den Zustand des autonomen Systems beschreiben, wird in dieser Arbeit das autonome System als Träger betrachtet.

Der Ursprung und die Ausrichtung der Koordinatenachsen hängt von der Anwendung des Trägers ab. Ein autonomes System hat die Aufgaben, autonom in einer unbekannten Welt zu navigieren und sich entsprechend zu bewegen. Aus diesem Grund wird der Ursprung des Koordinatensystems entweder in den Schwerpunkt des Trägers oder in das Sensorkoordinatensystem der Beschleunigungssensoren gelegt. Die Ausrichtung entspricht dabei der Hauptbewegungsrichtung des Trägers.

### Das Weltkoordinatensystem

Das Weltkoordinatensystem bezieht sich auf die Umgebung, in der sich der Träger bewegt. Es dient der Kartografie durch die Sensorwerte und zur Navigation des Trägers. Der Koordinatenursprung kann durch die \gls{GPS}-Position eindeutig festgelegt werden.

![Schematische Darstellung des Weltkoordinatensystems\label{fig:schematische_darstellung_des_weltkoordinatensystems}](Images/world_coordinatesystem.png)

## Koordinatentransformation nach Denavit-Hartenberg

- Bezug auf Eigen

Zur Verortung von Sensordaten in der globalen Weltkarte, müssen sie Schritt-für-Schritt vom Sensorkoordinatensystem in das Weltkoordinatensystem transformiert (überführt) werden. Diese Problematik ist vergleichbar mit der Bewegungsbeschreibung eines Roboterarmes. Dabei wird in jedes Gelenk ein Koordinatensystem gelegt, dessen Z-Achse in Richtung des nächsten Gelenks im Roboterarm zeigt. Folglich kann die Bewegung des Aktors durch die schrittweise Transformation zwischen den Gelenken oder durch eine einzige Transformationsmatrix beschrieben werden.

## Sensortechnik

Reflektivität, Laufzeitmessung, Fehlerbetrachtung

### Lasersanner

Laserscanner liefern die Messwerte im Allgemeinen in Polarkoordinaten. Dabei handelt es sich um Messwerte und Winkelangaben und sind abhängig vom Aufbau des \gls{LiDAR}.

- Verzerrung durch Bewegung
- Distanzfehler (+/- 10 cm)
- Winkelfehler

### Inertiale Messeinheiten

Aufbau:

- Gyro
- Beschleunigung

- Masseschwerpunkt wird als Hauptbezugssystem verwendet

#### Gyros

Fehlerquellen:

- Drift

#### Beschleunigungssensoren

Bewegungssensoren messen die Beschleunigungen in einer bestimmten Richtung und liefern meist skalare Messwerte. Werden mehrere Beschleunigungssensoren zusammengefasst, entsteht ein Sensorsystem, eine sogenannte \gls{IMU}. Dieses Sensorsystem liefert je nach Ausführung mehrdimensionale Messwerte zur Bestimmung von Position und Lage in der  befindlichen Welt beschreiben.

Fehlerquellen:

- Ungenauigkeit des Beschleunigungssensors

### Systeme zur globalen Positionsbestimmung

- Notwendigkeit bei der Kalibrierung, die IMU zu stabilisieren?

Fehlerquellen:

- fehlerhaftes GPS (bis zu 15 m)

### Systemfehler

- Zeitlicher Versatz der Messungen zwischen Sensoren (lösbar durch Synchronisation)
- Blindzeit (Sensoren messen in unterschiedlichen Intervallen)
- fehlerhafte Angaben zur Pose zueinander

## Algorithmen zur Transformation

### ICP der PCL

Fehlerquellen:

- Rechenungenauigkeiten durch Transformationen
- Elimination wichtiger Features bei Datenreduktion (z.B. Statistical Outlier Removal)

#  Kalibrierung von LiDAR-Sensoren zu Inertialen Messeinheiten

Sensoren stellen eine Grundlage der Wissensgewinnung für ein \gls{UA} dar. Dieses Wissen kann anschließend in verschiedenen Algorithmen verwendet werden, um Trajektorien zu planen, zu verfolgen oder weiterführende Entscheidungen zu treffen. Die Voraussetzung für dieses Wissen ist die Glaubwürdigkeit. Glaubwürdigkeit bedeutet dabei, dass zur genauen Verortung von Hindernissen deren genaue Position bekannt sein muss. Die Sensoren sind an jeweils unterschiedlichen Posen am Träger, dem \gls{UA}, angebracht. Einige Gründe dafür sind:

- variable Grundkonfigurationen, die je nach Flugauftrag unterschiedliche Sensoren transportieren,
- unterschiedliche Trägersysteme, da je nach Umgebung bestimmte \gls{UA} eingesetzt werden müssen (Größen- oder Gewichtsbestimmungen)
- verschiedene Beladungszustände, die eine Austarierung der Sensoren erfordern.

Daraus resultiert, dass für jede unterschiedliche Verwendung des \gls{UA} die Sensorparameter erneut kalibriert werden müssen. Bei bildgebenden Sensoren wie Kameras oder Laserscanner ist die genaue Bestimmung der Pose elementar, da es sonst nicht möglich ist, sichere und eindeutige Rückschlüsse auf die Umgebung ziehen zu können. Auf Grund einer nicht-planaren Trägeroberfläche und einer dynamischen Flotte an \gls{UA}'s gibt es bisher kein automatisiertes Verfahren zur Kalibrierung. Bisher werden die Konfigurationen stets von Hand vermessen und kalibriert. Dadurch kommt es zu großen Ungenauigkeiten und Inkonsistenzen in den Vermessenen Positionen. Des Weiteren ist die Vermessung der Lage des Sensors sehr schwierig.

Eine automatisierte Kalibrierung zwischen \gls{LiDAR} und \gls{IMU} Sensoren ermöglicht eine präzisere und deterministische Verwendung. Des Weiteren sollen die Träger problemlos angepasst oder ausgetauscht werden können. Die Kalibrierung soll eine genauere Bestimmung der Pose ermöglichen, als bisher von Hand möglich. Die folgenden Kapitel erläutern die verschiedenen in Betracht gezogenen Ansätze, beleuchten die jeweiligen Vor- und Nachteile und beschreiben die schlussendlich gewählte Implementierung.

## Problemanalyse

Die Bestimmung von Lage und Position im 3-dimensionalen Raum bezeichnet die Bestimmung von 6 Freiheitsgraden (\gls{6DoF}). Die 6 Freiheitsgrade werden in 3 translatorische und 3 rotatorische Freiheitsgrade unterteilt. Die translatorischen Freiheitsgrade bestimmen die Position in $X$-, $Y$-, und $Z$-Achse in einem Weltkoordinatensystem. Die rotatorischen Freiheitsgrade bestimmen die Lage an dieser Position in Bezug zur Erdoberfläche. Gemäß \ref{tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300} werden die 3 Eulerschen Winkeln $\Phi$ (Phi), $\Theta$ (Theta) und $\Psi$ (Psi) verwendet.

| Winkel   | Bezeichnung | Rotationsachse |
| :-----   | :-------    | :-----:        |
| $\Phi$   | Gierwinkel  | $Z$            |
| $\Theta$ | Nickwinkel  | $Y$            |
| $\Psi$   | Rollwinkel  | $X$            |

Table: Bezeichnung der Winkel gemäß DIN 9300 / ISO 1151-2:1985\label{tab:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300}

## Möglichkeiten zur Kalibrierung

Für die Kalibrierung der Sensoren werden folgende Anforderungen definiert:

- die Umgebung wird als unveränderlich und starr angenommen,
- die zu vermessende Bewegung muss größer als die größte Messungenauigkeit des Systems sein.

### Im Sensorkoordinatensystem

#### Ohne Bewegungskorrektur

\ref{fig:kalibrierung_im_sensorkoordinatensystem} zeigt die Kalibrierung im Sensorkoordinaten

![Kalibrierung im Sensorkoordinatensystem\label{fig:kalibrierung_im_sensorkoordinatensystem}](Images/kalibrierungImSC.pdf)

#### Mit Bewegungskorrektur

![Kalibrierung im Sensorkoordinatensystem mit Bewegungskorrektur\label{fig:kalibrierung_im_sensorkoordinatensystem_mit_korr}](Images/kalibrierungImSCmitKorr.pdf)

### Im Weltkoordinatensystem

#### Ohne Bewegungskorrektur

![Kalibrierung im Weltkoordinatensystem\label{fig:kalibrierung_im_weltkoordinatensystem}](Images/kalibrierungImWC.pdf)

#### Mit Bewegungskorrektur

![Kalibrierung im Weltkoordinatensystem mit Bewegungskorrektur\label{fig:kalibrierung_im_weltkoordinatensystem_mit_korr}](Images/kalibrierungImWCmitKorr.pdf)

# Validierung

Zur Validierung der Kalibrier-Lösung wurden zwei Experimente durchgeführt. Das erste Experiment dient zur Bestimmung des "Common Ground" anhand eines konstruierten und vermessenen Aufbaus. Das zweite Experiment dient der Erprobung an einem Flugversuch eines automatisierten Hubschraubers. Im Folgenden werden beide Experimente bezüglich ihres Aufbaus, des Ablaufs und den jeweiligen Resultaten erläutert.

## Einsatzgebiet

autonomer Hubschrauberflug

## Versuch - "Common Ground"

### Aufbau

**Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?**

Mit dem Experiment wird die Genauigkeit der Kalibrierungslösung bestimmt. Der Aufbau ist minimal und besteht rein aus den zur Kalibrierung benötigten Geräten.

#### Der Laserscanner

Als Laserscanner kommt der Velodyne HDL-32e (im Folgenden als Velodyne bezeichnet) zum Einsatz. Der Sichtbereich des Velodyne beträgt 360° um seine Y-Achse. Durch 32 vertikal angeordnete Laserquellen beträgt der Sichtbereich in der ZX-Ebene zwischen +10° und -30°. Der Messbereich liegt bei 1m bis 100m mit einer Standardabweichung von +/- 2cm bei 25m. Die horizontale Auflösung ist abhängig von der, vom Anwender eingestellten, Bildrate (Framerate). Die Framerate kann vom Benutzer zwischen 5Hz und 20Hz gewählt werden. Für diesen Versuch wurde die Framerate auf 10Hz eingestellt.

![Schematische Darstellung des Velodyne HDL-32e mit Koordinatensystem\label{fig:schematische_darstellung_des_velodyne_hdl-32e_mit_koordinatensystem}](Images/velodyne.png)

Der Laserscanner misst den Rotationswinkel $\Theta$, die Distanz zum Objekt, dem Intensitätswert des jeweiligen Hits (ein Hit bezeichnet den Auftreffpunkt des Laserstrahls auf einem Objekt) und einem Zeitstempel. Die aufgenommenen Sensordaten werden per \gls{UDP} an den Flugrechner weitergeleitet und dort in Sensorkorrdinaten transformiert.

#### Die inertiale Messeinheit

Als inertiale Messeinheit kommt die iMar \gls{IMU} iTraceRT-F400-Q zum Einsatz. Die \gls{IMU} bietet eine "Deep-Coupled" Sensorumgebung aus \gls{INS} und \gls{GNSS} 

|       | Antenne 1 | Antenne 2 |
| :-:   | :----:    | :------:  |
| **X** | 44.5      | -114.0    |
| **Y** | 11.0      | 0.0       |
| **Z** | -2.0      | -3.0      |

### Ablauf

Während eines Experimentalfluges werden in regelmäßigen Abständen Bewegungs- und Laserdaten aufgenommen. Die Abstände richten sich nach den jeweiligen Fähigkeiten der Sensoren.

```Bash
./dip/bin/obdip-release-linux64-g++
./artis/bin/itracert-logger-release-linux64-g++
```

### Ergebnisse

## Versuch - "In-Flight"

### Aufbau

Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?

### Ablauf

Während eines Experimentalfluges werden in regelmäßigen Abständen Bewegungs- und Laserdaten aufgenommen. Die Abstände richten sich nach den jeweiligen Fähigkeiten der Sensoren.

### Ergebnisse

## Gesamtresultat

# Fazit und Ausblick

1. Was wurde gemacht?
2. Was war das Resultat?
3. Was ergeben sich für Folgeaufgaben?
