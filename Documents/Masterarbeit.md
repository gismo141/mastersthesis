# Einführung

Das \gls{DLR} beschäftigt sich am Institut für Flugsystemtechnik mit der Forschung an unbemannten Luftfahrzeugen, die sich in unbekannten Gebieten fortbewegen. Zur erfolgreichen Navigation ist das Erkennen von Hindernissen notwendig. Die Grundlage dafür ist durch verschiedene Algorithmen, wie etwa der Pfadplanung, gegeben.

Bekannte Pfadplanungsansätze arbeiten mit Hinderniskarten, in denen die Hindernisse mit weiteren Eigenschaften (z.B. der Farbe, der Struktur der Oberfläche, etc.) vermerkt werden. Durch bildgebende Sensoren, wie Laserscanner und Kameras, können detektierte Hindernisse zu diesen Karten hinzugefügt oder die vermerkten Eigenschaften der Hindernisse verbessert werden.

## Problematik

Die Integration von erkannten Hindernissen in bestehende Hinderniskarten erfordert eine Transformation zwischen verschiedenen Koordinatensystemen (Sensor-, Träger- und Weltkoordinatensystemen). Diese Transformationen sind aufgrund der unterschiedlichen Position und Lage der Sensoren und Träger im 3-dimensionalen Raum notwendig, damit die Messungen korrekt verortet werden können.

Die Transformation der Sensordaten in das globale Koordinatensystem oder in andere Sensorkoordinatensysteme enthält oft unbekannte sowie variable Parameter. Dabei ist die genaue Position des Sensors im Gehäuse unbekannt oder die Position des Sensors auf dem Träger ist je nach Experiment unterschiedlich.

## Aufgabenstellung

Zur Bestimmung der Parameter, wird in dieser Arbeit ein Algorithmus entworfen, umgesetzt und validiert, der die relative extrinsische Transformation zwischen einem Laserscanner sowie einer \gls{IMU} mit \gls{GPS}, ermöglicht.

Ausgangspunkt für den zu entwerfenden Ansatz sind relative Translationen und Rotationen (\gls{6DoF}) des Laserscanners gegenüber der betrachteten Umwelt, die  mittels eines \gls{ICP} Algorithmus aus den Scandaten bestimmt werden. Über einen Abgleich der berechneten Transformation, der gemessenen Bewegung der \gls{IMU} und dem Einsatz einer nicht linearen Optimierung, wie Levenberg-Marquardt, wird anschließend die \gls{6DoF} Transformation zwischen den beiden Komponenten bestimmt.

Die Kalibrierung soll unabhängig von einem bekannten Kalibrierobjekt möglich sein. Vielmehr sollen generelle Features der Umwelt verwendet werden um während eines Kalibrierfluges die gesuchten Parameter zu ermitteln.

## Struktur der vorliegenden Arbeit

Im Kapitel \ref{} werden bestehende Ansätze erläutert und auf die Anwendung auf die Aufgabenstellung untersucht. Im Anschluss wird im Kapitel \ref{} der Ansatz zur Bestimmung der extrinsischen Parameter entworfen und die verwendete Optimierungsfunktion dargestellt. Damit die Parameter bestimmt werden können werden gemäß Kapitel \ref{} die notwendigen Randbedingungen erläutert, die für eine hinreichende Kalibrierung erforderlich sind (Flugprofil). Kapitel \ref{} zeigt die algorithmische Umsetzung des Ansatzes im vorhandenen \gls{DIP}-Framework des Instituts für Flugsystemtechnik. Des Weiteren wird die Umsetzung am praktischen Beispiel validiert.

# Grundlagen

In diesem Kapitel werden die geometrischen, mathematischen und algorithmischen Grundlagen erläutert.

## Die verwendeten Koordinatensysteme

Autonomes Fliegen erfordert verschiedene Sensoren, die die Umwelt des autonomen Systems vermessen. Bevor diese Daten in einen Zusammenhang gebracht werden können, müssen sie auf eine gemeinsame Datenbasis fusioniert werden. Bei Bildgebenden Sensoren entsteht eine Art Bild, entweder aus Pixeln in einem Array oder durch radiale Entfernungen. Diese Daten befinden sich in einem sogenannten Sensorkoordinatensystem und sind abhängig von der Realisierung des Sensors.

Viele Sensoren sind direkt auf dem autonomen System (z.B. bei dem Projekt \gls{ARTIS}) montiert und unterscheiden sich, in Bezug auf das Trägerkoordinatensystem, zusätzlich in Positionen und Lage zueinander.

Des Weiteren befindet sich das autonome System zu einem bestimmten Zeitpunkt in einer Lage und einer Position in seiner Umgebung. Dessen Bezugsort ist der Ursprung für das Weltkoordinatensystem.

### Das Sensorkoordinatensystem

Das Sensorkoordinatensystem ist je nach Sensor und Hersteller unterschiedlich definiert. Im Folgenden werden die Koordinatensysteme erläutert, die in dieser Arbeit hauptsächlich Anwendung finden.

#### Lasersanner

Laserscanner liefern die Messwerte im Allgemeinen in Polarkoordinaten. Dabei handelt es sich um Messwerte und Winkelangaben und sind abhängig vom Aufbau des Laserscanners.

#### Kamerasensoren

Eine Kamera hingegen liefert interpretierte Helligkeitsinformationen der Umgebung, die durch Objektive gewonnen werden, meist in Form eines 2-dimensionalen Bildes. Jeder Messpunkt ist durch zwei Koordinaten räumlich definiert und besteht je nach Ausführung der Kamera aus mehreren Messwerten.

#### Beschleunigungssensoren

Bewegungssensoren messen die Beschleunigungen in einer bestimmten Richtung und liefern meist skalare Messwerte. Werden mehrere Beschleunigungssensoren zusammengefasst, entsteht ein Sensorsystem, eine sogenannte \gls{IMU}. Dieses Sensorsystem liefert je nach Ausführung mehrdimensionale Messwerte, die die Position und Lage zur befindlichen Welt beschreiben.

### Das Trägerkoordinatensystem

Das Trägerkoordinatensystem beschreibt die Position und Lage der verschiedenen Sensoren zum Bezugspunkt des Trägers. Als Träger wird meist die Konstruktion bezeichnet, auf dem die Sensoren befestigt sind. Da in vielen Anwendungen auch Parameter gewünscht sind, die den Zustand des autonomen Systems beschreiben, wird in dieser Arbeit das autonome System als Träger betrachtet.

Der Ursprung und die Ausrichtung der Koordinatenachsen hängt von der Anwendung des Trägers ab. Ein autonomes System hat die Aufgaben, autonom in einer unbekannten Welt zu navigieren und sich entsprechend zu bewegen. Aus diesem Grund wird der Ursprung des Koordinatensystems entweder in den Schwerpunkt des Trägers oder in das Sensorkoordinatensystem der Beschleunigungssensoren gelegt. Die Ausrichtung entspricht dabei der Hauptbewegungsrichtung des Trägers.

### Das Weltkoordinatensystem

Das Weltkoordinatensystem bezieht sich auf die Umgebung, in der sich der Träger bewegt. Es dient der Kartografie durch die Sensorwerte und zur Navigation des Trägers. Der Koordinatenursprung kann durch die \gls{GPS}-Position eindeutig festgelegt werden.

## Koordinatentransformation nach Denavit-Hartenberg

Zur Verortung von Sensordaten in der globalen Weltkarte, müssen sie Schritt-für-Schritt vom Sensorkoordinatensystem in das Weltkoordinatensystem transformiert (überführt) werden. Diese Problematik ist vergleichbar mit der Bewegungsbeschreibung eines Roboterarmes. Dabei wird in jedes Gelenk ein Koordinatensystem gelegt, dessen Z-Achse in Richtung des nächsten Gelenks im Roboterarm zeigt. Folglich kann die Bewegung des Aktors durch die schrittweise Transformation zwischen den Gelenken oder durch eine einzige Transformationsmatrix beschrieben werden.

# Analyse

## Problembeschreibung

## Möglichkeiten zur Kalibrierung

Für die Kalibrierung der Sensoren werden folgende Anforderungen definiert:

- die Umgebung wird als unveränderlich und starr angenommen,
- die zu vermessende Bewegung muss größer als die größte Messungenauigkeit des Systems sein. 

### Bild zu Bild

Dieser Ansatz ist grundlegend als inkrementell zu betrachten. Eventuelle Fehler müssen durch geeignete Filtermaßnahmen minimiert werden. Des Weiteren muss evaluiert werden, welche Bewegungen für ungeeignet erachtet werden müssen.

#### Im Sensorkoordinatensystem

##### Ohne Bewegungskorrektur

werden gemäß Abbildung \ref{fig:ablaufdiagramm_zur_kalibrierung_im_sensorkoordinatensystem_ohne_korrektur} die Sensordaten direkt an den \gls{ICP} übergeben. Bewegt sich der Träger schneller, als der Laserscanner, führt dies bei Scans zu Verzerrungen der realen Objekte. Wird angenommen, dass die Bewegung während der Scans gleichförmig ist, wäre die Verzerrung auf beiden Bildern gleich.

![Ablaufdiagramm zur Kalibrierung im Sensorkoordinatensystem ohne Bewegungskorrektur\label{fig:ablaufdiagramm_zur_kalibrierung_im_sensorkoordinatensystem_ohne_korrektur}](Diagrams/kalibrierungImSCohneKorr.pdf)

\clearpage

##### Mit Bewegungskorrektur

Gemäß Abbildung \ref{fig:ablaufdiagramm_zur_kalibrierung_im_sensorkoordinatensystem_mit_korr} wird die aktuelle Position und Lage als Ausgangspose vermerkt und ein Laserscan der Umgebung durchgeführt. Anschließend wird eine Bewegung (vorzugsweise gekoppelt aus Translation und Rotation) und eine sogenannte Endpose erreicht. Diese Bewegung wurde durch die \gls{IMU} vermessen und ebenfalls abgespeichert. An der Endpose wird erneut ein Laserscan durchgeführt.

Die beiden Laserscans unterscheiden sich auf Grund der vollführten Bewegung voneinander. Die Transformation vom Laserscan der Endpose zum Laserscan der Ausgangspose wird durch die Verwendung des \gls{ICP}-Algorithmus erhalten.

Im realen System hingegen unterscheiden sich die Pose der \gls{IMU} und die Pose des Laserscanners. Diese Differenz wird durch den Abgleich der \gls{ICP}-Transformation und der \gls{IMU}-Bewegung bestimmt.

![Ablaufdiagramm zur Kalibrierung im Sensorkoordinatensystem mit Bewegungskorrektur\label{fig:ablaufdiagramm_zur_kalibrierung_im_sensorkoordinatensystem_mit_korr}](Diagrams/kalibrierungImSC.pdf)

\clearpage

#### Im Weltkoordinatensystem

Eine Kalibrierung im Weltkoordinatensystem erfordert im Vorhinein mehrere Transformationen bevor ein Abgleich der Sensordaten stattfinden kann. Des Weiteren werden für die Transformationen bereits die \gls{IMU}- und Montagedaten benötigt. Da diese zu Beginn fehlerhaft sind, handelt es sich bei dieser Lösung um einen inkrementellen Ansatz.

![Ablaufdiagramm zur Kalibrierung im Weltkoordinatensystem](Diagrams/kalibrierungImWC.pdf)

Das bedeutet, dass:

1. zwei Laserscans im Weltkoordinatensystem verglichen werden,
2. die verbesserte Montagepose bestimmt wird und
3. die Berechnung für die verbesserte Montagepose wiederholt wird

Dieses Prozedere wird so lange wiederholt, bis keine deutliche Verbesserung in der Montagepose erhalten werden kann. Es ist eindeutig, dass dieses Verfahren im Verhältnis zu den vorherigen deutlich fehlerbehafteter und rechenaufwendiger ist.

\clearpage

### Bild zu Welt

## Fehlerquellen

### Sensorfehler

- fehlerhaftes GPS (bis zu 15 m)
- IMU:
	* Drift des Gyros
	* Ungenauigkeit des Accelerometer
- Laserscanner:
	* Distanzfehler (+/- 10 cm)
	* Winkelfehler

### Systemfehler

- Zeitlicher Versatz der Messungen zwischen Sensoren (lösbar durch Synchronisation)
- Blindzeit (Sensoren messen in unterschiedlichen Intervallen)
- fehlerhafte Angaben zur Pose zueinander

### Rechenfehler

- Rechenungenauigkeiten durch Transformationen
- Elimination wichtiger Features bei Datenreduktion (z.B. Statistical Outlier Removal)

# Evaluierung

# Fazit und Ausblick