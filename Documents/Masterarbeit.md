# Einleitung

In den letzten Jahren hat die allgemeine Akzeptanz im Bereich des autonomen Fahrens stark zugenommen. Namhafte Hersteller wie Audi und BMW bieten bereits hochautomatisierte Fahrzeuge in ihrem Portfolio an, die den Fahrer in alltäglichen Situationen entlasten. Das Fahrzeug kann unter Kontrolle des Fahrers selbstständig einparken oder in Stausituationen die Spur sowie einen einprogrammierten Sicherheitsabstand zu den vorausfahrenden Fahrzeugen einhalten. Im Notfall können Notbremsungen vom Fahrzeug selbst eingeleitet oder dem Fahrer mögliche Ausweichmanöver mitgeteilt und initiiert werden.

Im Bereich der Luftfahrt werden Flugvorgänge automatisiert, um die Piloten von monotonen Aufgaben zu entlasten und die Fehleranfälligkeit zu minimieren. Automatisiert bedeutet dabei, dass bestimmte Funktionen vom Piloten aktiv an das System übergeben werden. Das System arbeitet anschließend anhand von festen Programmen die Aufgaben ab. Der Begriff der Autonomie wird in der Wissenschaft unterschiedlich aufgefasst, für diese Arbeit wird ein System als autonom betrachtet, wenn es seine Aktionen selbstständig plant, ausführt und auf Veränderungen der Umwelt entsprechend reagiert. Wird ein Pfad (sogenannten Trajektorie) durch einen Menschen vorgegeben und vom System abgeflogen, so wird dies hochautomatisiert, aber nicht als autonom, betrachtet.

Um einem System die Autonomie zu ermöglichen, müssen einige grundlegende Fähigkeiten gegeben sein. Die erste Bedingung an das System ist das selbstständige Planen von Trajektorien. Bekannte Pfadplanungsansätze arbeiten mit Hinderniskarten, in denen die Hindernisse mit verschiedenen Eigenschaften (wie z.B. der Farbe, der Oberflächenstruktur, etc.) vermerkt werden. Durch bildgebende Sensoren, wie Laserscanner und Kameras, können detektierte Hindernisse zu diesen Karten hinzugefügt oder die vermerkten Eigenschaften der Hindernisse verbessert werden.

Damit die von den Sensoren detektierten Hindernisse in die Karten eingetragen werden können, müssen die Sensordaten zwischen verschiedenen Koordinatensystemen (Sensor-, Träger- und Weltkoordinatensystemen) transformiert werden. Diese Transformationen sind aufgrund der unterschiedlichen Position und Lage der Sensoren auf dem Träger und des Träger im 3-dimensionalen Raum notwendig. Die Zusammensetzung einer Position und Lage wird als Pose bezeichnet.

Die Transformation der Sensordaten in das globale Koordinatensystem oder in andere Sensorkoordinatensysteme enthält oft unbekannte und variable Parameter. Einerseits ist die genaue Pose des Sensors im Gehäuse unbekannt und andererseits ist die Pose des Sensors auf dem Träger je nach Experiment unterschiedlich.

In dieser Arbeit wird eine Lösung präsentiert, die die Bestimmung der Montagepose von Laserscannern ermöglicht. Dabei werden Bewegungssensoren anhand einer \gls{IMU} sowie Sensoren zur Positionsbestimmung wie \gls{GPS} verwendet. Es werden verschiedene Varianten zur Kalibrierung auf ihre Genauigkeit und Verwendbarkeit untersucht:

a) Die Kalibrierung soll unabhängig von einem bekannten Kalibrierobjekt möglich sein,
b) generelle Features der Umwelt verwenden, um während eines Kalibrierfluges die gesuchten Parameter zu ermitteln.

Ausgangspunkt für den zu entwerfenden Ansatz sind relative Translationen und Rotationen (\gls{6DoF}) des Laserscanners zur betrachteten Umwelt. Diese werden durch einen \gls{ICP} Algorithmus aus den Scandaten bestimmt. Über den Abgleich der berechneten Transformation, der gemessenen Bewegung der \gls{IMU} und dem Einsatz einer nicht linearen Optimierung, wie Levenberg-Marquardt, wird anschließend die \gls{6DoF} Transformation zwischen den beiden Komponenten bestimmt.

# Grundlagen

In diesem Kapitel werden die geometrischen, mathematischen und algorithmischen Grundlagen erläutert.

## Die verwendeten Koordinatensysteme

Autonomes Fliegen erfordert verschiedene Sensoren, die die Umwelt des autonomen Systems vermessen. Bevor diese Daten in einen Zusammenhang gebracht werden können, müssen sie auf eine gemeinsame Datenbasis fusioniert werden. Bei Bildgebenden Sensoren entsteht eine Art Bild, entweder aus Pixeln in einem Array oder durch radiale Entfernungen. Diese Daten befinden sich in einem sogenannten Sensorkoordinatensystem und sind abhängig von der Realisierung des Sensors.

Viele Sensoren sind direkt auf dem autonomen System (z.B. bei dem Projekt \gls{ARTIS}) montiert und unterscheiden sich, in Bezug auf das Trägerkoordinatensystem, zusätzlich in Positionen und Lage zueinander.

Des Weiteren befindet sich das autonome System zu einem bestimmten Zeitpunkt in einer Lage und einer Position in seiner Umgebung. Dessen Bezugsort ist der Ursprung für das Weltkoordinatensystem.

### Das Sensorkoordinatensystem

Das Sensorkoordinatensystem ist je nach Sensor und Hersteller unterschiedlich definiert. Im Folgenden werden die Koordinatensysteme erläutert, die in dieser Arbeit hauptsächlich Anwendung finden.

### Das Trägerkoordinatensystem

Das Trägerkoordinatensystem beschreibt die Position und Lage der verschiedenen Sensoren zum Bezugspunkt des Trägers. Als Träger wird meist die Konstruktion bezeichnet, auf dem die Sensoren befestigt sind. Da in vielen Anwendungen auch Parameter gewünscht sind, die den Zustand des autonomen Systems beschreiben, wird in dieser Arbeit das autonome System als Träger betrachtet.

Der Ursprung und die Ausrichtung der Koordinatenachsen hängt von der Anwendung des Trägers ab. Ein autonomes System hat die Aufgaben, autonom in einer unbekannten Welt zu navigieren und sich entsprechend zu bewegen. Aus diesem Grund wird der Ursprung des Koordinatensystems entweder in den Schwerpunkt des Trägers oder in das Sensorkoordinatensystem der Beschleunigungssensoren gelegt. Die Ausrichtung entspricht dabei der Hauptbewegungsrichtung des Trägers.

### Das Weltkoordinatensystem

Das Weltkoordinatensystem bezieht sich auf die Umgebung, in der sich der Träger bewegt. Es dient der Kartografie durch die Sensorwerte und zur Navigation des Trägers. Der Koordinatenursprung kann durch die \gls{GPS}-Position eindeutig festgelegt werden.

## Koordinatentransformation nach Denavit-Hartenberg

- Bezug auf Eigen

Zur Verortung von Sensordaten in der globalen Weltkarte, müssen sie Schritt-für-Schritt vom Sensorkoordinatensystem in das Weltkoordinatensystem transformiert (überführt) werden. Diese Problematik ist vergleichbar mit der Bewegungsbeschreibung eines Roboterarmes. Dabei wird in jedes Gelenk ein Koordinatensystem gelegt, dessen Z-Achse in Richtung des nächsten Gelenks im Roboterarm zeigt. Folglich kann die Bewegung des Aktors durch die schrittweise Transformation zwischen den Gelenken oder durch eine einzige Transformationsmatrix beschrieben werden.

## Sensortechnik

Reflektivität, Laufzeitmessung, Fehlerbetrachtung

### Lasersanner

Laserscanner liefern die Messwerte im Allgemeinen in Polarkoordinaten. Dabei handelt es sich um Messwerte und Winkelangaben und sind abhängig vom Aufbau des Laserscanners.

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

Bewegungssensoren messen die Beschleunigungen in einer bestimmten Richtung und liefern meist skalare Messwerte. Werden mehrere Beschleunigungssensoren zusammengefasst, entsteht ein Sensorsystem, eine sogenannte \gls{IMU}. Dieses Sensorsystem liefert je nach Ausführung mehrdimensionale Messwerte, die die Position und Lage zur befindlichen Welt beschreiben.

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

#  Kalibrierung von Laserscannern zu Inertialen Messeinheiten

Hauptteil

## Problembeschreibung

## Möglichkeiten zur Kalibrierung

Für die Kalibrierung der Sensoren werden folgende Anforderungen definiert:

- die Umgebung wird als unveränderlich und starr angenommen,
- die zu vermessende Bewegung muss größer als die größte Messungenauigkeit des Systems sein. 

### Ohne Bewegungskorrektur



#### Im Sensorkoordinatensystem

![Kalibrierung im Sensorkoordinatensystem\label{fig:kalibrierung_im_sensorkoordinatensystem}](../Diagrams/kalibrierungImSC.pdf)

#### Im Weltkoordinatensystem

![Kalibrierung im Weltkoordinatensystem\label{fig:kalibrierung_im_weltkoordinatensystem}](../Diagrams/kalibrierungImWC.pdf)

### Mit Bewegungskorrektur

#### Im Sensorkoordinatensystem

![Kalibrierung im Sensorkoordinatensystem mit Bewegungskorrektur\label{fig:kalibrierung_im_sensorkoordinatensystem_mit_korr}](../Diagrams/kalibrierungImSCmitKorr.pdf)

#### Im Weltkoordinatensystem

![Kalibrierung im Weltkoordinatensystem mit Bewegungskorrektur\label{fig:kalibrierung_im_weltkoordinatensystem_mit_korr}](../Diagrams/kalibrierungImWCmitKorr.pdf)

# Validierung

## Einsatzgebiet

autonomer Hubschrauberflug

## Aufbau

Welche Sensorprodukte werden wie verwendet (Eigenschaften, Auflösungen etc.)?

## Ablauf

## Ergebnisse

## Gesamtresultat

# Fazit und Ausblick

1. Was wurde gemacht?
2. Was war das Resultat?
3. Was ergeben sich für Folgeaufgaben?
