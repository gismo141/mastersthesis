# Anhang

Zur Reproduktion der Forschung wird im Folgenden die Entwicklungsumgebung vorgestellt. Für konkrete Information zur Installation wird einerseits auf die jeweilige Dokumentation für das Programm sowie auf das Github-Repository [gismo141/laserIMUCalibration](https://github.com/gismo141/laserIMUCalibration) als Begleitmaterial der vorliegenden Arbeit verwiesen.

Die Implementierung der Algorithmen erfolgte zur Erprobung und Herleitung in Python und in C++ zur Integration in das vorhandene Framework. Dabei wurden die Betriebssysteme Mac OS X 10.10.3 und Windows 7 verwendet. Es wurde darauf Wert gelegt, Open-Source Software zu verwenden.

## Entwicklungsumgebung

Zur bequemen Installation der benötigten Programme wird für Mac OS X ein Paketmanager wie [Homebrew](http://brew.sh) oder [MacPorts](https://www.macports.org) empfohlen. Eventuelle Abhängigkeiten können somit während der Installation festgestellt und aufgelöst werden. Homebrew trennt dabei die vom Benutzer installierten von den systemweiten Programmen, um Komplikationen zu verhindern.

Die benötigte Software kann auch gemäß Tabelle \ref{tab:notwendige_programme_zur_erstellung_der_arbeit_und_ihrer_abhängigkeiten} von Hand heruntergeladen, kompiliert und installiert werden.

Table: Notwendige Programme zur Erstellung der Arbeit und Ihrer Abhängigkeiten\label{tab:notwendige_programme_zur_erstellung_der_arbeit_und_ihrer_abhängigkeiten}

| Paket    | Version  | Verwendung                                                 |
| :---     | :-----   | :----                                                      |
| Qt5      | 5.4.2    | UI-Design (Oberflächenentwicklung)                         |
| VTK      | 6.2.0    | Visualisierung der Daten und Algorithmen                   |
| PCL      | 1.7.2    | Algorithmen zum Umgang mit Punktwolken (ICP, Outlier etc.) |
| CMake    | 3.2.2    | einheitliche Build-Umgebung                                |
| Python   | 2.7      | schnelles Algorithmen-Prototyping                          |
| Pandoc   | 1.13.2.1 | Erstellung der Masterarbeit in unterschiedlichen Formaten  |
| GraphViz | 2.38.0   | Visualisierung der Graphen und Algorithmen                 |
| Doxygen  | 1.8.9.1  | Dokumentation des Quellcodes                               |
| Gnuplot  | 5.0.0    | Plotten der gewonnenen Daten                               |
