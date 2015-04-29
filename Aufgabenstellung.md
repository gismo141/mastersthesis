---
title: Aufgabenstellung zur Masterarbeit
subtitle: Relative extrinsische Kalibrierung von bildgebenden Umweltsensoren
date: \vspace{-5ex}
documentclass: scrartcl
classoption: |
    fontsize=12pt
    , paper=a4
    , twoside=false
    , DIV12
    , BCOR=1cm
    , numbers=noenddot
    , headings=small
    , headlines=1.5
    , final
geometry: |
    top=2.5cm
    , left=2.5cm
    , right=2.5cm
    , bottom=4cm
    , includehead
    , a4paper
lang: ngerman
---

# Hintergrund

Das DLR beschäftigt sich am Institut für Flugsysteme mit der Forschung an unbemannten Luftfahrzeugen, die sich in unbekannten Gebieten fortbewegen. Zur erfolgreichen Navigation ist das Erkennen von Hindernissen notwendig. Die Grundlage dafür ist durch verschiedene Algorithmen, wie etwa der Pfadplanung, gegeben.

Bekannte Pfadplanungsansätze arbeiten mit Hinderniskarten, in denen die Hindernisse mit zur Navigation relevanten Eigenschaften (z. B. ihrer Position und Ausmaße) vermerkt werden. Durch bildgebende Sensoren (z. B. Laserscanner oder Kameras) können detektierte Hindernisse zu diesen Karten hinzugefügt werden oder die Eigenschaften der Hindernisse erweitert/verbessert werden.

# Problematik

Die Integration von erkannten Hindernissen in bestehende Hinderniskarten erfordert eine Transformation zwischen verschiedenen Koordinatensystemen (z. B. von Sensorkoordinatensystem in Fahrzeugkoordinatensystem und anschließend in das Koordinatensystem der Hinderniskarte). Diese Transformation ist aufgrund der unterschiedlichen Montagepositionen der Sensoren am Fahrzeug und der Lage des Fahrzeugs im 3-dimensionalen Raum notwendig.

Die Transformation der Sensordaten in das globale Koordinatensystem oder in andere Sensorkoordinatensysteme enthält oft unbekannte Parameter. Durch Fertigungstoleranzen bei der Produktion von Sensorsystemen kann die wahre Position des Sensors (z. B. dem CMOS-Chip einer Digitalkamera) im Gehäuse nicht genau bestimmt werden.

# Aufgabenstellung

Zur Bestimmung der Parameter, soll in dieser Arbeit ein Algorithmus entworfen, umgesetzt und verifiziert werden. Der Algorithmus soll die relative extrinsische Transformation zwischen einem Laserscannern sowie einer inertialen Messeinheit (IMU), ermöglichen.

Ausgangspunkt für den zu entwerfenden Ansatz sollen relative Translationen und Rotationen (6DoF) des Laserscanners gegenüber der betrachteten Umwelt sein, die beispielsweise mittels eines einem Iterative Closest Point (ICP) Algorithmus aus den Scannerdaten bestimmt werden können. Über einen Abgleich der korrespondieren Messgrößen zwischen Laserscanner und IMU und den Einsatz eine nicht linear Optimierung, wie Levenberg-Marquardt, soll anschließend der 6DoF Transformation zwischen den beiden Komponenten bestimmt werden.

Die Kalibrierung soll unabhängig von einem bekannten Kalibrierobjekt möglich sein. Vielmehr sollen generelle Features der Umwelt verwendet werden um während eines Kalibrierfluges online die gesuchten Parameter zu ermitteln.

Die Aufgabenstellung wird in folgende Aufgaben unterteilt:

- Sichtung und Bewertung von Literatur zu bereits bestehenden Ansätzen
- Entwurf eines Ansatzes zu Bestimmung der extrinsischen Parameter
- Erstellen einer Optimierungsfunktion
- Definition von Randbedingungen, die für eine hinreichende Kalibrierung erforderlich sind (Flugprofil)
- Umsetzung des Entwurfes
- Erstellung eines Filters in einem vorhandene Bildverarbeitungs-Framework
- Anpassungen der gegeben ICP Implementierung (falls ICP gewählt)
- Test und Anpassung der bestimmten Optimierungsfunktion
- Verifikation des umgesetzten Ansatzes 

# Kontakt

--------------- -------------------------------
Ansprechpartner Stefan Krause

Adresse         German Aerospace Center \newline
                Institute of Flight Systems \newline
                Department of Unmanned Aircraft \newline
                Lilienthalplatz 7 \newline
                38108 Braunschweig, Germany

Telefon         +49 531 295-2602

Fax             +49 531-295-2647

E-Mail          stefan.krause@dlr.de
-----------------------------------------------
