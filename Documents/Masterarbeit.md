# Einleitung

Das \glspl{DLR} erforscht am Institut für Flugsystemtechnik in der Abteilung für \gls{ULF} die automatisierte Bewegung von \gls{UA} in unbekanntem Luftraum. Zur erfolgreichen Navigation wird eine Karte benötigt, die im Flug aufgebaut werden muss.

Dafür machen bildgebende Sensoren in zeitlichen Abständen Aufnahmen von der Umgebung. Diese Momentaufnahmen müssen für die korrekte Kartographie mit Bewegungsdaten des \gls{UA} in Beziehung gebracht werden.

Aus bautechnischen Gründen befinden sich die Bewegungs- und die Bildgebungssensoren in der Regel an unterschiedlicher Position und Ausrichtung am \gls{UA}. Damit eine korrekte Kartographie möglich ist, müssen diese Sensoren zueinander kalibriert werden (in Beziehung gebracht werden).

Bisher wird diese Kalibrierung manuell und für jeden Flug neu angefertigt. Dabei werden die Entfernungen und die Lage zwischen den Sensoren von Hand vermessen. Dieses Verfahren ist aufwendig und fehleranfällig. Aus diesen Gründen sollte das Verfahren automatisiert werden.

Deshalb wird für diese Arbeit folgende Forschungsfrage formuliert: *"Ist es möglich, die Kalibrierung von bildgebenden Sensoren relativ zu Bewegungssensoren zu automatisieren?"* Der präsentierte Ansatz behandelt die automatisierte Kalibrierung von \gls{LiDAR}-Sensorn als bildgebende Sensoren zu Bewegungssensoren (bestehend aus einer \gls{IMU} mit \gls{GNSS}).

Zuerst werden die Gemeinsamkeiten zweier aufeinanderfolgender Laserscans identifiziert und die eventuelle Bewegung zwischen den Scans durch einen \gls{ICP}-Algorithmus geschätzt. Das Fachgebiet zur Schätzung von Bewegungen aus Bildinformationen wird als visuelle Odometrie oder auch Ego-Motion (engl.), bezeichnet.

Parallel werden Navigationsdaten mittels einer \gls{IMU} und eines \gls{GNSS} aufgezeichnet. Aus diesen Daten wird eine Bewegung bestimmt und im Anschluss mit der Schätzung des \gls{ICP} verglichen. Da sich die drei Sensoren (\gls{IMU}, \gls{GNSS} und \gls{LiDAR}-Sensor) zueinander statisch auf einer Plattform befinden, muss die Differenz der zwei geschätzten Bewegungen (Bewegung des bildgebenden Sensors/ Bewegung der Navigationssensoren) das Resultat einer unterschiedlichen Position und Lage (Montagepose) zwischen \gls{LiDAR}-Sensor und der Kombination aus \gls{IMU} und \gls{GNSS} sein. Diese Differenz entspricht den gesuchten Parametern für die relative Kalibrierung.

Die vorliegende Arbeit ist in drei Hauptkapitel unterteilt. Das Kapitel Grundlagen gibt einen Einblick in die physikalischen Grundlagen der verwendeten Sensoren, in die mathematischen Grundlagen zur Verarbeitung der Messdaten und in die verschiedenen Datenstrukturen für die algorithmische Verknüpfung. Im Anschluss wird der Ansatz zur relativen extrinsischen Kalibrierung präsentiert, der während der Masterarbeit als Filter im \gls{DIP}-Framework^[Das \gls{DIP}-Framework dient seit 2004 als Plattform zur Evaluation digitaler Bildverarbeitungsalgorithmen in der Abteilung \gls{ULF} am \gls{DLR}. Für weitere Informationen zur grundlegenden Idee und den Hintergründen des Frameworks siehe @Guth2004 und @Goormann2004.] implementiert wurde. Den Abschluss bildet die Validierung der Kalibrierung in zwei voneinander unabhängigen Experimenten.

# Grundlagen

Zum besseren Verständnis der Arbeit werden in den folgenden Abschnitten die Grundlagen in den Bereichen der Mathematik, Sensortechnik, Bezugssystemen und komplexen Datenstrukturen gelegt.

## Mathematik und Geometrie

Koordinatensysteme bilden die Grundlage, um die Position und Lage in einem mehrdimensionalen Raum zu definieren. Durch Rotationen und Translationen  können die Koordinatensysteme zueinander transformiert werden. <!-- In dieser Arbeit werden kartesische und polare Koordinatensysteme verwendet. -->

<!-- Ein kartesisches Koordinatensystem besteht aus orthogonal zueinander stehenden Achsen. Zwei orthogonale Achsen spannen eine gemeinsame Ebene auf. Durch eine dritte orthogonale Achse entstehen weitere zwei Ebenen, die zusammen mit der ersten Ebene einen 3-dimensionalen euklidischen Raum bilden. Durch die Angabe von Koordinaten in Form von Vektoren (Werte auf der jeweiligen Achse in einer festen Reihenfolge) können nun Punkte im 3-dimensionalen Raum definiert werden. Die Achsen werden nach dem rechtshändigen System mit $x$, $y$ und $z$ bezeichnet. Gemäß Abbildung @fig:karthesisches_koordinatensystem hat der Punkt A die Position $1$ auf der $x$-Achse, $2$ auf der $y$-Achse und $3$ auf der $z$-Achse. Die Schreibweise als Vektor erfolgt gemäß (@eq:vektor) in der Reihenfolge $x$ (oben), $y$ (mitte) und $z$ (unten).

$$ \vec{v_A} := \begin{pmatrix} 1\\2\\3 \end{pmatrix} $$ {#eq:vektor}

Die Angabe der Lage erfolgt durch die Definition von Rotationen. Eine Rotation bezeichnet die Drehung um eine Achse in einem bestimmten Winkel. Abbildung @fig:karthesisches_koordinatensystem zeigt die Zuordnung der Winkel zu den jeweiligen Achsen. Die Drehrichtung der Winkel ist dabei stets vom Koordinatenursprung zeigend entgegen dem Uhrzeigersinn.^[Zur Verdeutlichung kann die sogenannte "Rechte-Hand"-Regel verwendet werden. Dabei zeigt der gestreckte Daumen der rechten Hand vom Koordinatenursprung nach außen, die restlichen Finger werden gekrümmt. Die Richtung der Krümmung ist dabei entgegen dem Uhrzeigersinn.] Durch die Kombination von Rotationen um alle drei Achsen kann der Punkt in allen Richtungen gedreht werden. -->

<!-- ### Rotation im 2-dimensionalen Raum

Eine Drehung entspricht der Änderung der Position durch einen Winkel, wofür man sich gemäß (@eq:x_und_y_im_einheitskreis) des polaren Koordinatensystems bedient. Durch die Angabe eines Radius $r$ sowie einem Winkel $\phi$ lassen sich die $x$- und $y$-Anteile der Position in Form des Sinus-Kosinussatzes auf einem Kreis beschreiben.

$$ \begin{pmatrix}
x\\
y
\end{pmatrix}
=
\begin{pmatrix}
r * \cos{\phi}\\
r * \sin{\phi}
\end{pmatrix} $$ {#eq:x_und_y_im_einheitskreis}

Möchte man nun die Polarkoordinaten um den Winkel $\theta$ rotieren, so erhält man gemäß (@eq:x_und_y_prime) die neue Position $x^\prime$ und $y^\prime$.

$$ \begin{pmatrix}
x^\prime\\
y^\prime
\end{pmatrix}
=
\begin{pmatrix}
r * \cos{(\theta + \phi)}\\
r * \sin{(\theta + \phi)}
\end{pmatrix} $$ {#eq:x_und_y_prime}

Unter Verwendung der Additionstheoreme kann die Addition gemäß (@eq:additionstheoreme) aufgeteilt werden.

$$ \begin{pmatrix}
x^\prime\\
y^\prime
\end{pmatrix}
=
\begin{pmatrix}
r * (\cos{\theta} * \cos{\phi} - \sin{\theta} * \sin{\phi})\\
r * (\sin{\theta} * \cos{\phi} + \cos{\theta} * \sin{\phi})
\end{pmatrix} $$ {#eq:additionstheoreme}

Durch Ausmultiplizieren gemäß (@eq:ausmultiplizieren) erkennt man einen Zusammenhang zu (@eq:x_und_y_im_einheitskreis).

$$ \begin{pmatrix}
x^\prime\\
y^\prime
\end{pmatrix}
=
\begin{pmatrix}
(r * \cos{\phi}) * \cos{\theta} - (r * \sin{\phi}) * \sin{\theta})\\
(r * \cos{\phi}) * \sin{\theta} + (r * \sin{\phi}) * \cos{\theta})
\end{pmatrix} $$ {#eq:ausmultiplizieren}

Ersetzt man nun die $r * \cos{\phi}$ und $r * \sin{\phi}$ Terme mit $x$ und $y$ gemäß (@eq:x_und_y_im_einheitskreis) so erhält man (@eq:x_und_y_prime_mit_x_und_y).

$$ \begin{pmatrix}
x^\prime\\
y^\prime
\end{pmatrix}
=
\begin{pmatrix}
x * \cos{\theta} - y * \sin{\theta})\\
x * \sin{\theta} + y * \cos{\theta})
\end{pmatrix} $$ {#eq:x_und_y_prime_mit_x_und_y}

Gleichung (@eq:x_und_y_prime_mit_x_und_y) entspricht nun einer Multiplikation aus einer Matrix mit einem Vektor, wie sie in Gleichung (@eq:x_und_y_prime_mit_x_und_y_exkludiert) zu sehen ist.

$$ \begin{pmatrix}
x^\prime\\
y^\prime
\end{pmatrix}
=
\begin{pmatrix}
\cos{\theta} & -\sin{\theta}\\
\sin{\theta} & \cos{\theta}
\end{pmatrix}
*
\begin{pmatrix}
x\\
y
\end{pmatrix}$$ {#eq:x_und_y_prime_mit_x_und_y_exkludiert}

Allgemein lässt sich die Gleichung nun gemäß (@eq:rotationsmatrix) als Rotationsmatrix $R$ beschreiben, die einen Vektor $\vec{v}$ in den Vektor $\vec{v^\prime}$ rotiert.

$$ \vec{v^\prime} = R * \vec{v} $$ {#eq:rotationsmatrix}
 -->
### Lageänderung durch Rotation<!--  im 3-dimensionalen Raum -->

<!-- Der vorherige Abschnitt erläuterte die Rotation im 2-dimensionalen Raum anhand der $2 \times 2$-Matrix $R$. Für die Rotation im 3-dimensionalen Raum hat man jedoch Vektoren mit drei Koordinatenachsenanteilen.  -->Die Rotation eines Vektors $(x, y, z)$ erfolgt <!-- demzufolge --> mit einer $3 \times 3$-Matrix. Die Grundlage bildet dabei die Identitätsmatrix $I$, die sich dadurch auszeichnet, gemäß (@eq:identitaetsmatrix) auf der Diagonalen mit 1 und auf allen anderen Feldern mit 0 besetzt zu sein.

$$ I = \begin{pmatrix}
1 & 0 & 0\\
0 & 1 & 0\\
0 & 0 & 1
\end{pmatrix} $$ {#eq:identitaetsmatrix}

Die Identitätsmatrix sorgt dafür, dass die Rotation um die Achse erfolgt und der Wert dieser Achse gleich bleibt. Möchte man nun den Vektor $(x, y, z)$ mit $R$ um die $z$-Achse rotieren, so bleibt der Anteil der $z$-Koordinate gleich, wohingegen die Anteile $x$ und $y$ zu $x^\prime$ und $y^\prime$ verändert werden. Es resultiert die Gleichung (@eq:rotation_um_z) in Matrixschreibweise und (@eq:rotation_um_z_kurz) in Kurzform.

$$ \begin{pmatrix}
x^\prime\\
y^\prime\\
z^\prime
\end{pmatrix}
=
\begin{pmatrix}
\cos{\phi} & -\sin{\phi} & 0\\
\sin{\phi} &  \cos{\phi} & 0\\
0 & 0 & 1
\end{pmatrix}
*
\begin{pmatrix}
x\\
y\\
z
\end{pmatrix} $$ {#eq:rotation_um_z}

$$ \vec{v^\prime} = R_z(\phi) * \vec{v} $$ {#eq:rotation_um_z_kurz}

Die Kurzform $R_z{\phi}$ bezeichnet die Achse und den dazugehörigen Winkel, um den gedreht wird. Für eine anschließende Rotation um die $y$-Achse resultiert (@eq:rotation_um_zy).

$$ \begin{pmatrix}
x^{\prime\prime}\\
y^{\prime\prime}\\
z^{\prime\prime}
\end{pmatrix}
=
\begin{pmatrix}
\cos{\theta} & 0 & -\sin{\theta}\\
0 & 1 & 0\\
\sin{\theta} & 0 &  \cos{\theta}
\end{pmatrix}
*
\begin{pmatrix}
x^{\prime}\\
y^{\prime}\\
z^{\prime}
\end{pmatrix} $$ {#eq:rotation_um_zy}

$$ \vec{v^{\prime\prime}} = R_y(\theta) * \vec{v^\prime} $$ {#eq:rotation_um_zy_kurz} 

Abschließend wird in diesem Beispiel um die $x$-Achse rotiert. Es resultieren die Gleichungen (@eq:rotation_um_zyx) und (@eq:rotation_um_zyx_kurz).

$$ \begin{pmatrix}
x^{\prime\prime\prime}\\
y^{\prime\prime\prime}\\
z^{\prime\prime\prime}
\end{pmatrix}
=
\begin{pmatrix}
1 & 0 & 0\\
0 & \cos{\psi} & -\sin{\psi}\\
0 & \sin{\psi} &  \cos{\psi}
\end{pmatrix}
*
\begin{pmatrix}
x^{\prime\prime}\\
y^{\prime\prime}\\
z^{\prime\prime}
\end{pmatrix} $$ {#eq:rotation_um_zyx}

$$ \vec{v^{\prime\prime\prime}} = R_x(\psi) * \vec{v^\prime\prime} $$ {#eq:rotation_um_zyx_kurz}

Dieses schrittweise Vorgehen erleichtert das Verständnis, erschwert jedoch die Rechnung. Gemäß (@eq:zusammenfassung_der_rotationen) und (@eq:zusammenfassung_der_rotationen_kurz) werden die einzelnen Matrizenmultiplikationen zusammengefasst. Es ist jedoch zu beachten, dass die Multiplikation von Matrizen nicht kommutativ, also nicht tauschbar, ist, da sonst eine andere Gesamtrotation resultiert.

$$ \begin{pmatrix}
x^{\prime\prime\prime}\\
y^{\prime\prime\prime}\\
z^{\prime\prime\prime}
\end{pmatrix}
=
\begin{pmatrix}
1 & 0 & 0\\
0 & \cos{\psi} & -\sin{\psi}\\
0 & \sin{\psi} &  \cos{\psi}
\end{pmatrix}
*
\begin{pmatrix}
\cos{\theta} & 0 & -\sin{\theta}\\
0 & 1 & 0\\
\sin{\theta} & 0 &  \cos{\theta}
\end{pmatrix}
*
\begin{pmatrix}
\cos{\phi} & -\sin{\phi} & 0\\
\sin{\phi} &  \cos{\phi} & 0\\
0 & 0 & 1
\end{pmatrix}
*
\begin{pmatrix}
x\\
y\\
z
\end{pmatrix} $$ {#eq:zusammenfassung_der_rotationen}

$$ \vec{v^{\prime\prime\prime}} = R_x(\psi) * R_y(\theta) * R_z(\phi) * \vec{v} $$ {#eq:zusammenfassung_der_rotationen_kurz}

Für die nachfolgende Matrix wurde $\sin$ durch $s$ und $\cos$ durch $c$ ersetzt. Durch Ausmultiplizieren erhält man gemäß Gleichung (@eq:zusammenfassung_der_rotationen_ausmultipliziert) und (@eq:zusammenfassung_der_rotationen_ausmultipliziert_kurz) eine gesamte Rotationsmatrix $R_{zyx}$. Somit minimiert man die Rechnung von drei einzelnen Rotationen zu einer einzigen Rotation. Durch Einsetzen verschiedener Winkel $\phi$, $\theta$ und $\psi$ kann nun jeder Vektor im 3-dimensionalen Raum rotiert werden.

$$ \begin{pmatrix}
x^{\prime\prime\prime}\\
y^{\prime\prime\prime}\\
z^{\prime\prime\prime}
\end{pmatrix}
=
\begin{pmatrix}
c\theta~c\phi & -c\theta~s\phi & -s\theta\\
-s\psi~s\theta~c\phi + s\phi~c\psi  & s\psi~s\theta~s\phi + c\psi~c\phi & -s\psi~c\theta\\
c\psi~s\theta~c\phi + s\psi~s\phi & -c\psi~s\theta~s\phi + s\psi~c\phi &  c\psi~c\theta 
\end{pmatrix}
*
\begin{pmatrix}
x\\
y\\
z
\end{pmatrix}
$$ {#eq:zusammenfassung_der_rotationen_ausmultipliziert}

$$ \vec{v^{\prime\prime\prime}} = R_{zyx}(\phi,\theta,\psi) * \vec{v} $$ {#eq:zusammenfassung_der_rotationen_ausmultipliziert_kurz}

### Positionsänderung durch Translation <!-- im mehrdimensionalen Raum -->

Wie in den vorherigen Abschnitten beschrieben, können Punkte in Form von Vektoren durch die Multiplikation mit Rotationsmatrizen gedreht werden. Als nächstes wird die Verschiebung einer Position $P_1$ auf eine Position $P_2$ betrachtet. Verallgemeinert kann das Problem gemäß (@eq:translation_als_funktion) als Funktion formuliert werden, wobei die Position $P_1$ als Vektor $\vec{v}$ einer Funktion $F(x)$ übergeben wird. Das Resultat der Funktion ist die neue Position $P_2$ als Vektor $\vec{v^\prime}$.

$$ \vec{v^\prime} = F(\vec{v}) $$ {#eq:translation_als_funktion}

Die kürzeste Verbindung zwischen zwei Punkten ist stets die Gerade. Durch die Addition des Vektors $\vec{v}$ mit einem Vektor $\vec{v}_{Translation}$ wird gemäß (@eq:vektoraddition) die Position $P_1$ an die Position $P_2$ verschoben, sodass die Funktion $F(x)$ eine Vektoraddition ist.

$$ \begin{pmatrix}
5\\
1\\
1 
\end{pmatrix}_{v^\prime}
=
\begin{pmatrix}
2\\
3\\
0
\end{pmatrix}_{v}
+
\begin{pmatrix}
3\\
-2\\
1
\end{pmatrix}_{v_{Translation}} $$ {#eq:vektoraddition}

Die Translation eines Punktes beschreibt somit die Verschiebung entlang einer Geraden.

### Transformation von Punktmengen

Durch die Rotation kann die Lage, durch die Translation die Position eines Punktes verändert werden. Werden beide Operationen in einem Schritt durchgeführt, spricht man von einer Transformation. Eine Transformation kann ebenfalls in Form einer Matrix dargestellt werden. Dazu wird die Rotationsmatrix sowie der Translationsvektor in einer $4 \times 4$-Transformationsmatrix $T$ gemäß (@eq:transformations_matrix) abgelegt.

$$ T = \begin{pmatrix}
R_0 & R_1 & R_2 & \Delta x\\
R_3 & R_4 & R_5 & \Delta y\\
R_6 & R_7 & R_8 & \Delta z\\
0 & 0 & 0 & 1\\
\end{pmatrix}  $$ {#eq:transformations_matrix}

Die Transformationsmatrix $T$ ermöglicht es nun, jeden Vektor durch Rotation zu drehen und durch Translation zu bewegen. Dadurch können nun Beziehungen zwischen mehreren Posen beschrieben werden. Anwendung findet dies zum Beispiel in der Sensortechnik, wenn Messwerte verschiedener bildgebender Sensoren auf Grund unterschiedlicher Blickrichtungen in ein gemeinsames Bezugssystem überführt werden sollen. Dabei wird jeder Punkt $P_n$ einzeln in die neue Pose transformiert.

Die Rücktransformation bezeichnet die umgekehrte Transformation. Dabei wird gemäß der Matrizenrechnung von der Transformationsmatrix $T$ die Inverse $T^{-1}$ gebildet, sodass anschließend gemäß (@eq:ruecktransformation) jeder Punkt rücktransformiert werden kann.

$$ \vec{v} = T^{-1} * \vec{v^\prime} $$ {#eq:ruecktransformation}

### Der Gradient als Richtung und Maß des steilsten Anstiegs

Der Gradient $g$ bezeichnet in der Mathematik einen Differentialoperator. Angewandt auf ein Skalarfeld^[Ein Skalarfeld bezeichnet in der Analysis eine Funktion, die jedem Punkt eines Raumes ein Skalar (eine reelle Zahl) zuordnet.] liefert der Gradient ein Vektorfeld^[Ein Vektorfeld bezeichnet eine Funktion, die jedem Punkt eines Raumes einen Vektor zuordnet.].

Bezogen auf eine Landkarte, die in Form der Funktion $h(x,y)$ allen Punkten in der $xy$-Ebene eine Höhe $h$ zuordnet, bezeichnet der Gradient $g(h(x,y))$ einen Vektor in der $xy$-Ebene in Richtung des steilsten Anstiegs von $h$. Die Länge des Vektors ist ein Maß für die Steilheit an diesem Punkt. Die Bildung des Gradienten wird mit dem Nabla-Operator $\nabla$ gekennzeichnet. Der Gradient wird durch die partiellen Ableitungen $\frac{\partial f}{\partial x_i}$ von $f$ in Richtung $x_i$ gebildet. Für den 3-dimensionalen Raum wird der Gradient gemäß (@eq:gradient) berechnet.

$$ \text{grad}(f) = \nabla f = \frac{\partial f}{\partial x} \vec{e_x} + \frac{\partial f}{\partial y} \vec{e_y} + \frac{\partial f}{\partial z} \vec{e_z} $$ {#eq:gradient}

Alternativ kann der Gradient als Spaltenvektor gemäß (@eq:gradient_spaltenvektor) dargestellt werden.

$$ \nabla f =
\begin{pmatrix}
\frac{\partial f}{\partial x}\\
\frac{\partial f}{\partial y}\\
\frac{\partial f}{\partial z}
\end{pmatrix} $$ {#eq:gradient_spaltenvektor}

Die Vektoren $\vec{e_x}$, $\vec{e_y}$ und $\vec{e_z}$ bezeichnen dabei die Einheitsvektoren in Richtung der Koordinatenachsen.

Geben sei das Skalarfeld gemäß (@eq:skalarfeld_beispiel).

$$ f(x,y) = 5y^2 + 3x^2 $$ {#eq:skalarfeld_beispiel}

Dieses Skalarfeld wird gemäß (@eq:partial_x) nach $x$ und (@eq:partial_y) nach $y$ partiell abgeleitet. 

$$ \frac{\partial f}{\partial x} = 6x $$ {#eq:partial_x}

$$ \frac{\partial f}{\partial y} = 10y $$ {#eq:partial_y}

Es ergibt sich der Gradiant gemäß (@eq:gradient_beispiel) und (@eq:gradient_beispiel_vektor) in Vektordarstellung.

$$ grad(f) = \nabla f = 6x * \vec{e_x} + 10y * \vec{e_y} $$ {#eq:gradient_beispiel}

$$ grad(f) = \nabla f =
\begin{pmatrix}
6x\\
10y
\end{pmatrix} $$ {#eq:gradient_beispiel_vektor}

Anwendung findet der Gradient unter Anderem im Bereich der Bestimmung der Optimierungsrichtung nach Levenberg-Marquardt im Abschnitt \ref{nichtlineare-optimierung-nach-levenberg-marquardt}.

## Sensortechnik

Umweltwahrnehmung ist für uns Menschen eine überlebenswichtige Fähigkeit. Durch unsere Sinne erkennen wir unser Umfeld, können die Umgebung klassifizieren und bedrohliche Situationen erkennen. Bedrohlich bezeichnet dabei Situationen, in denen entweder wir, unsere Mitmenschen oder unser geplantes Handeln (zum Beispiel die Durchführung eines Auftrags) gefährdet sind. Ein großer Bestandteil unserer Wahrnehmung ist visuell und erfolgt durch unsere Augen.

### Visuelle Odometrie durch LiDAR-Sensoren

In automatisierten Systemen werden bildgebende Sensoren zur visuellen Wahrnehmung verwendet. Diese Sensoren erstellen in zeitlichen Abständen ein Bild, das aus Messgrößen eines realen Objektes besteht. Die Messgröße oder eine daraus abgeleitete Information hat einen geographischen Bezug und wird über Helligkeitswerte oder Farben kodiert visualisiert.

Die visuelle Odometrie, auch Ego-Motion (engl.), bezeichnet das Fachgebiet zur Schätzung von Bewegungen aus Bildinformationen. Dabei werden Veränderungen von Merkmalen (Features) aus verschiedenen Aufnahmen der Umwelt bestimmt. Welche Merkmale verwendet werden, ist abhängig von der Struktur der eingegebenen Daten.

Man unterscheidet organisierte und unorganisierte Datensätze. Organisierte Daten bezeichnen eine Matrix-ähnliche Struktur, in der die Daten in Zeilen und Spalten unterteilt sind. Sensoren, die organisierte Daten erzeugen, sind zum Beispiel Digitalkameras oder \gls{ToF}-Kameras. Der Vorteil von organisierten Daten ist, dass durch die Kenntnis von Beziehungen zwischen benachbarten Punkten (z.B. Pixeln), Algorithmen, wie die Suche nach dem nächsten Nachbarn, effizienter gestaltet werden können.

Des Weiteren ist die Erkennung von Merkmalen abhängig von der Qualität der vorliegenden Messungen. Qualität bezeichnet dabei das Zueinanderpassen mehrerer Datensätze. Unterschiede, die durch Rotation, Translation, Skalierung oder Messrauschen verursacht werden, erfordern unterschiedliche Ansätze zur Extraktion von Merkmalen. In dieser Arbeit werden statische Posen der Sensoren zueinander vorausgesetzt. Das heißt, dass Unterschiede zwischen verschiedenen Bildern rein aus der Bewegung der Sensorplattform (Träger) und aus systembedingten Messfehlern resultieren.

#### Exemplarischer Aufbau und Funktionsweise eines LiDARs

\gls{LiDAR}-Sensoren dienen der optischen Abstandsmessung. Einsatzgebiete sind unter anderem topographische Geländeaufnahmen (Kartographie) [@Lindenberger1993], Detektion und Tracking von Hindernissen [@Mendes2004] und die Identifikation atmosphärischer Eigenschaften [@Wulfmeyer1998; @Browell1998].

![Schematischer Aufbau eines LiDAR nach @Kern2003](Images/Exemplarischer_Aufbau_eines_LiDAR_schematisch.pdf) {#fig:aufbau_LiDAR}

Ein \gls{LiDAR} besteht exemplarisch gemäß Abbildung @fig:aufbau_LiDAR aus einem \gls{LASER} als Emitter, einer Photodiode als Detektor, einer Signalverarbeitungseinheit, einem Modulator und einem Gehäuse. Die Laserquelle erzeugt energiereiches Licht, das anschließend das Gehäuse verlässt. Der am Hindernis reflektierte Laserstrahl trifft auf den Detektor im Gehäuse, um nach verschiedenen physikalischen Eigenschaften ausgewertet zu werden.

##### Funktionsweise eines LASERs

Laserlicht entsteht durch Absorption und spontane sowie stimulierte Emission von Ladungsträgern in einem aktiven Medium (das Material des \gls{LASER}s).

###### Absorption

Absorption bezeichnet den Vorgang, bei dem die Energie eines Photons von einem Elektron aufgenommen wird und es dadurch auf ein höheres Energieniveau gebracht wird.

###### Emission

Nach einer gewissen Verweilzeit auf dem höheren Energieniveau fällt das Elektron wieder auf das niedere Energieniveau hinab, wobei ein Photon mit der Energiedifferenz der Niveaus emittiert wird. Dieser Vorgang bezeichnet die spontane Emission. Zusätzlich kann der Übergang gezielt durch den photoelektrischen Effekt ausgelöst werden (stimulierte Emission).

Durch die wechselseitige Absorption und Emission kann es zu einer Verstärkung des Lichts im \gls{LASER} kommen. Dafür ist es notwendig, dass die resultierende elektromagnetische Welle weniger durch Absorption geschwächt, als durch Emission verstärkt wird. Dies erreicht man durch eine Besetzungsinversion (es befinden sich mehr Teilchen auf dem höheren Energieniveau). Durch konstantes "Pumpen", zum Beispiel durch Anlegen einer elektrischen Spannung, wird das aktive Medium in der Besetzungsinversion gehalten.

##### Aufbau eines LASERs

Um eine Verstärkung des Lichts zu ermöglichen, ist der \gls{LASER} in Form eines Resonators aufgebaut. Das aktive Medium befindet sich zwischen zwei Spiegeln, an denen die elektromagnetische Welle reflektiert wird.

Das aktive Medium befindet sich zwischen zwei Spiegeln, die im Abstand $d$ angeordnet sind. Ein Spiegel ist halbdurchlässig, das heißt er reflektiert nur einen Teil der elektromagnetichen Welle und transmittiert den Rest ($R<1$). Die effektive optische Weglänge des Lichts im Resonator $L$ ist abhängig vom Brechungskoeffizienten $n$ und errechnet sich gemäß $L = n * d$.

\gls{LASER} unterscheiden sich im verwendeten aktiven Medium, der erzeugten Energiedichte in Form von Sicherheitsklassen sowie dem Betriebsmodus. Als Betriebsmodi unterscheidet man Dauerlicht- oder Pulsbetrieb. Dauerlichtbetrieb erzeugt einen konstanten Laserstrahl geringer Energiedichte, wohingegen der Pulsbetrieb kurze Lichtimpulse mit hoher Energiedichte ermöglicht. Aktive Medien sind Festkörper, Gase, Farbstoffe und Halbleiter. Sie ermöglichen Laserlicht unterschiedlicher Wellenlängen, Bandbreiten und Energiedichten.

##### Optische Eigenschaften des LASERs

Durch die exakte Abstimmung des optischen Verstärkers und des Resonators entsteht ein divergentes, monochromatisches Licht hoher Energiedichte.

###### Monochromatisch

Ein \gls{LASER} erzeugt Licht einer schmalen spektralen Bandbreite, weswegen es als monochromatisch bezeichnet wird. Die Wellenlänge des Lichts ist dabei abhängig vom verwendeten aktiven Medium. Durch die Kombination verschiedener optischer Effekte können auch mehrere Wellenlängen im \gls{LASER} erzeugt werden.

###### Zeitliche und räumliche Kohärenz

Kohärenz bezeichnet die Gleichartigkeit und Gleichförmigkeit mehrerer Lichtwellen. Zeitliche Kohärenz ist bei Laserstrahlen in Form von Interferenzmustern aus Wellenbergen und Wellentälern zu beobachten. Räumliche Kohärenz bezeichnet das Maß, inwieweit sich zwei Wellenzüge aus der gleichen Quelle in unterschiedlichen Richtungen, an unterschiedlichen Orten zur selben Zeit unterscheiden.

###### Divergenz

Im \gls{LASER} erzeugtes Licht ist divergent, das heißt, der Durchmesser des Laserstrahls weitet sich relativ zu seiner Ausbreitungsgeschwindigkeit auf. Der Grund besteht in der Beugung des Strahls beim Austritt aus dem Gehäuse. Der Laserstrahl kann durch eine Sammellinse gebündelt werden, wodurch jedoch auch die Intensität des Strahls sinkt.

##### Absorption, Transmission und Reflexion

Trifft der Laserstrahl auf ein Hindernis, so wird er teilweise vom Hindernis absorbiert (aufgenommen), transmittiert (durchgelassen) und reflektiert (zurückgeworfen). Wie stark sich der jeweilige Effekt auswirkt, ist abhängig von der Beschaffenheit der Hindernisse, dem Winkel zwischen auftreffendem Laserstrahl und Hindernis sowie der Wellenlänge des Laserstrahls.

Gemäß Abbildung \ref{fig:reflexion} bezeichnet die Reflexion das Zurückstrahlen auf einer Ebene. Dabei ist der Eintrittswinkel $\alpha$ gleich dem Austrittswinkel $\beta$, gemessen zum Lot der Reflexionsfläche. Daraus resultiert, dass idealisierte parallele Strahlen auch wieder parallel reflektiert werden.

\begin{figure}[h!]
    \centering
    \subcaptionbox{Reflexion an einer ebenen Fläche\label{fig:reflexion}}
        [.5\linewidth]
        {\includegraphics[width=.5\linewidth]{Images/reflexion}}%
    \subcaptionbox{Diffuse Reflexion durch Streuung an einer unebenen Fläche\label{fig:diffuse_reflexion}}
        [.5\linewidth]
        {\includegraphics[width=.5\linewidth]{Images/Diffuse_Reflexion}}%
    \caption{Varianten der Reflexion von Licht}
    \label{fig:varianten_der_reflexion_von_licht}
\end{figure}

Treffen die Lichtstrahlen jedoch auf eine unebene Fläche, so kommt es gemäß Abbildung \ref{fig:diffuse_reflexion} auf Grund von Streuung zur diffusen Reflexion. Die ankommenden, idealisiert-parallelen Strahlen werden normalverteilt von der Oberfläche reflektiert.

Treffen die Lichtstrahlen auf durchlässige Hindernisse, so kommt es an der Oberfläche neben Reflexion auch zur Beugung und Transmission. Die vom \gls{LASER} ausgesendete elektromagnetische Welle wird somit teilweise von den Hindernissen absorbiert, teilweise zurückgeworfen. Durch die optischen Wechselwirkungen hat die elektromagnetische Welle an Leistung verloren und unter anderem eine Phasenverschiebung erfahren. Die Photodiode am \gls{LiDAR} wertet anschließend das empfangene Signal gegenüber dem versendeten Signal aus.

#### Messen von Entfernungen

\gls{LiDAR}-Sensoren werden zur Messung von Entfernungen zwischen Sensor und Umgebung verwendet. Hauptsächlich unterscheidet man zwischen der Messung der Signallaufzeit, der Phasenverschiebung und der Triangulation. Durch die Auswertung der Intensität der reflektierten Laserstrahlen können Aussagen über das Material und den Aggregatzustand des gemessenen Hindernisses gemacht werden.

##### Messung der Signallaufzeit

Die Bestimmung von Entfernungen durch Messung der Signallaufzeit entspricht der Funktionsweise des \gls{RaDAR}. Mit der Auskopplung des Laserstrahls wird am \gls{LASER} eine Zeitmessung gestartet. Durch Differenzbildung von Austritts- und Eintrittszeitpunkt des Laserstrahls wird gemäß (@eq:laufzeit) die Laufzeit bestimmt.

$$ t_{Laufzeit} = t_{Eintritt} - t_{Austritt} $$ {#eq:laufzeit}

Da die gemessene Laufzeit den Hin- und Rückweg bezeichnet, hat der Laserstrahl die doppelte Wegstrecke zurückgelegt. Mit der Ausbreitungsgeschwindigkeit von Licht $c$ wird die halbierte Laufzeit gemäß (@eq:distanzmessung) multipliziert.

$$ s = \frac{t_\text{Laufzeit}}{2} * c $$ {#eq:distanzmessung}

Die erhaltene Wegstrecke $s$ ist die Entfernung zwischen dem \gls{LiDAR}-Sensor und dem Hindernis.

##### Messung der Phasenverschiebung

Die Ausbreitungsgeschwindigkeit von Licht ist abhängig von dem Medium, in dem es sich bewegt. Durch den Zusammenhang zwischen Lichtgeschwindigkeit $c$ und Wellenlänge $\lambda$ kann gemäß (@eq:c_zu_wellenlaenge_und_frequenz) die Frequenz berechnet werden.

$$ c = \lambda * f $$ {#eq:c_zu_wellenlaenge_und_frequenz}

Die Frequenz $f$ ist dabei gemäß (@eq:omega_zu_frequenz) direkt in die Kreisfrequenz $\omega$ umformbar. Durch Bildung des Verhältnisses zwischen der gemessenen Phasenverschiebung $\delta$ und der konstruktionsbedingten Kreisfrequenz $\omega$ kann gemäß (@eq:phasenverschiebung) die Signallaufzeit des Laserstrahls berechnet werden.

$$ \omega = 2 * \pi * f $$ {#eq:omega_zu_frequenz}

$$ t_{Laufzeit} = \frac{\delta}{\omega} $$ {#eq:phasenverschiebung}

Anhand des vorherigen Abschnitts kann aus der berechneten Laufzeit der Abstand zwischen Hindernis und Sensor bestimmt werden.

##### Messung durch Triangulation

Einige \gls{LiDAR}-Sensoren ermitteln den Abstand zu einem Hindernis mittels Triangulation. Der Detektor eines solchen Systems besteht aus einer Kamera, einer ortsauflösenden Photodiode oder einer \gls{CCD}-Zelle. Der emittierte Laserstrahl wird je nach Entfernung in einem unterschiedlichen Winkel auf dem Detektor wahrgenommen, sodass sich auch die Position des Abbildes am Detektor ändert. Dafür wird der Abstand zwischen Emitter und Detektor $d$ benötigt. 

Der Detektor wird so ausgerichtet, dass der Laserstrahl bei einer mittleren Entfernung auch mittig auf dem Sensor detektiert wird. Dieser Winkel zwischen der Ausrichtung des Detektors und der Emitter-Detektor-Achse wird als $\alpha$ bezeichnet.

Bewegt man das Hindernis, so resultiert die veränderte Distanz in einer Änderung des Auftreffwinkels $\delta$. Dieser Winkel ändert sich proportional zur gemessenen Position des reflektierten Laserstrahls im Detektor.

Nun kann der Abstand $s$ zwischen der Emitter-Detektor-Einheit und dem Hindernis berechnet werden.

$$ s = d * \tan{(\alpha + \delta)} = d * \frac{\tan{\alpha} + \tan{\delta}}{1 - \tan{\alpha} * \tan{\delta}} $$ {#eq:triangulation}

#### Messtechnische Besonderheiten

Für diese Arbeit werden \gls{LiDAR}-Sensoren verwendet, die Entfernungen zu Hindernissen mittels Laufzeitmessung bestimmen. Diese Messvariante unterliegt dabei verschiedenen Einflüssen.

##### Abschattung

Abschattung bezeichnet die Problematik, dass Hindernisse, die sich in hinter anderen Hindernissen befinden, nicht durch \gls{LiDAR}-Sensoren gemessen werden können. Es kann somit nur eine Aussage über die Umgebung bis zum ersten Hindernis gemacht werden. 

##### Teildurchlässigkeit

Je nach aktivem Medium werden die Laserstrahlen von Hindernissen, wie Glas oder Wasser, stärker transmittiert, reflektiert oder absorbiert. Bei der Verwendung von einer grünen Laserstrahlung ($\approx 500$ nm $\to 600$ nm) werden die Strahlen an Glas hauptsächlich transmittiert, sodass Hindernisse aus diesem Material nicht detektiert werden können. Für die bathymetrische Vermessung^[Bathymetrische Vermessung bezeichnet die Vermessung der topographischen Gestalt von Gewässerbetten, Meeresböden und Seegründen.] werden aus diesem Grund Feststofflaser wie Nd:YAG (Neodym-dotierter Yttrium-Aluminium-Granat) verwendet, die kollineare Laserpulse zweier Wellenlängen (Rot $\equiv 1064$ nm für die Wasseroberfläche und Grün $\equiv 532$ nm für den Untergrund) erzeugen.

##### Messen in Bewegung

\gls{LiDAR}-Sensoren übertragen ihre Messwerte meist in Datenpaketen. Diese Datenpakete bestehen aus zusammengefassten Messreihen, denen ein Zeitstempel zugeordnet wird. Wird der \gls{LiDAR} während seiner Messung bewegt, müssen die Zeitstempel zwischen den einzelnen Messungen interpoliert werden, da sonst der geographische Bezug der Datenpunkte verfälscht wird.

### Messung der inertialen Bewegung und globalen Position

Lage und Position im 3-dimensionalen Raum werden als \gls{6DoF} bezeichnet, wobei die 6 Freiheitsgrade in 3 translatorische und 3 rotatorische Freiheitsgrade unterteilt werden. Die translatorischen Freiheitsgrade definieren die Position bezüglich $x$-, $y$-, und $z$-Achse in einem Koordinatensystem. Die rotatorischen Freiheitsgrade bestimmen die Lage an dieser Position durch Rotationen um die Koordinatenachsen. Gemäß Tabelle @tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300 werden die 3 Eulerschen Winkel $\Phi$ (Phi), $\Theta$ (Theta) und $\Psi$ (Psi) verwendet.

Table: Bezeichnung der Winkel gemäß DIN 9300 / ISO 1151-2:1985. {#tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300}

| Bezeichnung        | Winkel   | Rotationsachse     |
| :-------           | :-----:  | :-----:            |
| Rollwinkel (Roll)  | $\Phi$   | $x^{\prime\prime}$ |
| Nickwinkel (Pitch) | $\Theta$ | $y^\prime$         |
| Gierwinkel (Yaw)   | $\Psi$   | $z$                |

<!-- ![Schematische Darstellung des Weltkoordinatensystems nach WGS84](Images/world_coordinatesystem.png) {#fig:weltkoordinatensystem} -->

Das Bezugssystem ist <!-- gemäß Abbildung @fig:weltkoordinatensystem --> das \gls{WGS84}. Dabei handelt es sich um ein geodätisches Referenzsystem, das eine einheitliche Positionsangabe auf der Erde und im erdnahen Weltraum ermöglicht. Die Bestandteile sind ein Referenzellipsoid, ein zusätzliches detailliertes Modell \gls{EGM96} gemäß @Lemoine1998 und einem Satz dreidimensionaler Koordinaten von 12 über der Erde verteilten Fundamentalstationen. Das Zentrum des Koordinatensystems ist der Massenschwerpunkt der Erde inklusive der Atmosphäre. Die Orientierung der Achsen ist relativ zum Referenzmeridian und Referenzpol. Die zeitliche Entwicklung (die schrittweise Nummerierung der Längengrade) folgt zudem der Rotation der Erdkruste.

#### Globale Positionsbestimmung durch Satellitensysteme

\gls{GNSS} werden zur absoluten Positionsbestimmung im 3-dimensionalen Raum nach dem \gls{WGS84} eingesetzt. Die bekanntesten eingesetzten Systeme sind das vom russischen Verteidigungsministerium eingesetzte \gls{GLONASS}, das chinesische BeiDou, Galileo der \gls{ESA} und der Europäischen Union und das amerikanische \gls{NAVSTAR-GPS}. In dieser Arbeit wird das \gls{NAVSTAR-GPS} verwendet, dessen Aufbau sowie die Funktionsweise im Folgenden erläutert werden.

##### Aufbau

Das \gls{NAVSTAR-GPS}-System besteht gemäß @USA1995 aus einem Weltraumsegment, einem Kontrollsegment und einem Benutzersegment.

###### Das Weltraumsegment

Das Weltraumsegment umfasst 24 bis 32 Satelliten, die in einer mittleren Bahnhöhe von $20.200$ km zweimal pro Sterntag^[Bei einem Sterntag handelt es sich um den Zeitraum zwischen zwei oberen Kulminationen des Frühlingspunkts, verursacht durch die Eigendrehung der Erde. Ausgedrückt in \gls{SI}-Einheiten beträgt ein Sterntag 23 Stunden, 56 Minuten und 4,091 Sekunden.] um die Erde kreisen. Die Satelliten sind dabei so verteilt, dass überall auf der Erde und zu jeder Zeit ein \gls{GPS}-Empfänger die Signale von mindestens vier Satelliten empfangen kann. Dabei sind die Satelliten um $55^\circ$ gegen die Äquatorebene inkliniert (geneigt) und gegeneinander um jeweils $60^\circ$ verdreht. Jeder Satellit sendet kontinuierlich ein Datensignal von insgesamt 37.500 Bit mit einer Datenrate von 50 Bit/s. Die vollständige Übertragung benötigt somit circa 12,5 Minuten. Als gemeinsame Zeitbasis werden in den einzelnen Satelliten mehrere Atomuhren eingesetzt, die es ermöglichen, dass die Satelliten bis zu $10^{-14}$ Sekunden synchron laufen.

Das Datensignal setzt sich dabei aus 25 Frames zusammen. Die Frames sind wiederum in fünf Subframes unterteilt, deren erstes Wort das *telemetry word* ist. Das *telemetry word* enthält Informationen zur Aktualität der Ephemeridendaten.^[Ephemeriden sind Positionswerte, Bahndaten sich bewegender astronomischer Objekte.] Es folgt das *hand over word*, das die Anzahl der sogenannten Z-Epochen seit dem letzten Sonntag 0 Uhr enthält.

Nach diesen zwei Wörtern folgen im ersten Subframe die Daten zur Genauigkeit, dem Zustand und den Uhrenkorrekturwerten des sendenden Satelliten. Im zweiten und dritten Subframe werden die Ephemeridendaten übertragen. Das vierte Subframe enthält das sogenannte Refraktionsmodell sowie die Almanachdaten^[Im Vergleich zu den Ephemeriden enthält der Almanach weniger genaue, aber dafür länger gültige Bahndaten, die um Informationen über die Integrität der ausgestrahlten Signale (technischer Zustand, momentane Konfiguration und die Identifikationsnummer) ergänzt sind.] der Satelliten 25 bis 32. Das Refraktionsmodell besteht aus Ionosphärenkorrekturdaten, speziellen Nachrichten sowie \gls{UTC}-Zeitinformationen. Das letzte Subframe enthält die Almanachdaten der Satelliten 1 bis 24 sowie die Uhrzeit des Satelliten und die \gls{GPS}-Wochennummer. Die \gls{GPS}-Zeit unterscheidet sich dabei von der \gls{UTC}-Zeit. Die \gls{UTC}-Zeit wird mit Hilfe von Schaltsekunden regelmäßig der Erddrehung angepasst. Die \gls{GPS}-Zeit nicht, sodass sie sich aktuell circa 19 Sekunden unterscheiden.

###### Das Kontrollsegment

Das Kontrollsegment dient der Überwachung des Weltraumsegments. Jeder Satellit wird bezüglich seiner Bewegung und seines technischen Zustandes in Kontrollzentren auf der Erde beobachtet, die Ephemeriden- sowie die Almanachdaten berechnet und die Zeiten der Satelliten synchronisiert. Diese neuen Informationen werden im Anschluss an alle in Kontakt stehenden Satelliten übertragen (bei \gls{NAVSTAR-GPS} alle 2 Stunden). Befindet sich ein Satellit nicht auf seiner gewünschten Umlaufbahn, wird der Satellit als *not good* markiert, die Triebwerke werden gezündet und der Satellit wird neu positioniert. Sobald sich die Umlaufbahn des Satelliten wieder stabilisiert hat, wird der Status wieder auf *good* gesetzt.

###### Das Benutzersegment

Das Benutzersegment bezeichnet den \gls{GPS}-Empfänger der Satellitendaten. Er besteht aus mindestens einer Antenne, einer Berechnungseinheit sowie, aus Kostengründen und Machbarkeit, aus einer einfachen Quarzuhr. Der Empfänger dient der Berechnung der globalen Position, die durch Auswertung der Satellitensignale bestimmt wird. Satelliten, die vom Kontrollsegment als *not good* markiert wurden, werden von den \gls{GPS}-Empfängern ignoriert, da sonst die Betrachtung ihrer Daten zu Berechnungsfehlern führt.

Wurde der Empfänger komplett von der Spannungsversorgung getrennt, spricht man von einem *cold start*. Dabei muss die interne ungenaue Uhr mit der Satellitenzeit synchronisiert werden. Im Anschluss werden alle Almanach- und Ephemeridendaten empfangen, was im schlimmsten Fall auf Grund der Datenrate bis zu 12,5 Minuten dauern kann. Durch Auswertung der Almanachdaten und der Vorgabe einer groben Position durch den Anwender kann die Zeit bis zur Positionsbestimmung reduziert werden.

War der Empfänger weniger als 2 Stunden außer Betrieb, mit einer Spannungsversorgung verbunden und weniger als 300 km von der letzten bekannten Position entfernt, so spricht man von einem *hot start*. In diesem Modus werden Daten von bereits bekannten Satelliten empfangen. Treffen die Bedingungen für einen *hot* oder *cold start* nicht zu, spricht man von einem *warm start*.

##### Funktionsweise

Die Grundlage der Positionsbestimmung mittels \gls{GPS} ist die Entfernungsmessung zwischen einem Empfänger zu mehreren Sendern. Die Sender sind dabei die Satelliten, die auf höheren Erdumlaufbahnen kreisen. Das Verfahren zur Positionsbestimmung heißt Trilateration. Die Position der Satelliten ändert sich auf Grund der stetigen Bewegung auf ihren Umlaufbahnen. Somit ist auch die Position der Satelliten im Verhältnis zum Empfänger stets unterschiedlich. Durch Betrachtung der Ephemeriden- und Almanachdaten kann der Empfänger die Satellitenstandorte zu jedem Zeitpunkt berechnen. Bei \gls{NAVSTAR-GPS} und Galileo handelt es sich bei den Ephemeriden um keplersche Bahnelemente^[Keplersche Bahnelemente beschreiben die Bewegung eines astronomischen Objekts gemäß den Keplerschen Gesetzen im Schwerefeld eines Himmelskörpers.], wohingegen es bei \gls{GLONASS} Koordinaten-, Geschwindigkeits- und Beschleunigungsvektoren sind.

Die Satelliten vermerken den Sendezeitpunkt einer Übertragung im \gls{GPS}-Zeitsystem, beim Empfang setzt das Bodensegment den Empfangszeitpunkt. Durch Differenzbildung von Empfangs- und Sendezeitpunkt kann theoretisch durch Betrachtung der Lichtgeschwindigkeit die Entfernung zwischen Satellit und Empfänger bestimmt werden. Diese momentane Entfernung ist auf Grund von Fehlern der Uhren (Empfänger und Satellit) und weiteren Einflüssen wie atmosphärischen Eigenschaften ungenau.

\begin{figure}[hbtp!]
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics[width=.8\linewidth]{Images/gps_1_satellit}
      \caption{Variation auf der Kugeloberfläche}
      \label{fig:gps_1_satellit}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics[width=.8\linewidth]{Images/gps_2_satelliten}
      \caption{Variation auf dem Umkreis der Schnittfläche}
      \label{fig:gps_2_satelliten}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics[width=.8\linewidth]{Images/gps_3_satelliten}
      \caption{Ungefähre Position auf der Schnittfläche}
      \label{fig:gps_3_satelliten}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics[width=.8\linewidth]{Images/gps_4_satelliten}
      \caption{Positionsbestimmung durch Zeitkorrektur}
      \label{fig:gps_4_satelliten}
    \end{subfigure}
    \caption[Auswirkung der Satellitenzahl auf die Positionsbestimmung bei GNSS]{Auswirkung der Satellitenzahl auf die Positionsbestimmung bei GNSS (orange markiert die möglichen Positionen des Empfängers E und S markiert den/die nummerierten Satelliten)}
    \label{fig:auswirkung_der_satellitenzahl}
\end{figure}

Abbildung \ref{fig:auswirkung_der_satellitenzahl} zeigt die Auswirkungen, die die Anzahl der Satellitenzahl auf die Positionsbestimmung bei \gls{GNSS} hat. Ein einzelner Satellit reicht gemäß Abbildung \ref{fig:gps_1_satellit} nur zur Positionsbestimmung des Empfängers auf einer Kugeloberfläche rund um die aktuelle Position des Satelliten aus. Durch einen zweiten Satelliten wird die potenzielle Position des Empfängers auf den Umkreis des Schnitts der zwei Satellitenkugeln reduziert. Trotz eines dritten Satelliten ist die Positionsbestimmung im Schnittpunkt aller Kugelschnitte nicht eindeutig, da der Empfänger meist mit einer ungenaueren Uhr ausgestattet ist, als die Satelliten.

Die Empfängeruhr wird durch sogenanntes *Pseudoranging* synchronisiert. Dabei werden Pseudostrecken herangezogen, die von den wahren Distanzen um einen konstanten, aber vorerst unbekannten Betrag abweichen. Im 2-dimensionalen Raum werden dazu durch den Schnitt von zwei Bögen gemäß Abbildung \ref{fig:gps_2_satelliten} zwei Schnittpunkte gefunden. Einer der beiden Schnittpunkte kann aus Grund der Plausibilität vernachlässigt werden. Im 3-dimensionalen Fall handelt es sich dabei nicht um zwei Schnittpunkte, sondern den Umkreis, der durch den Schnitt zweier Kugeln entsteht. Weichen nun beide Bögen im Radius um den gleichen konstanten aber unbekannten Wert ab, werden die Schnittpunkte fehlerhaft. Man spricht dann von einem schleifenden Schnitt. Durch die Messung eines dritten, um den gleichen konstanten unbekannten Wert abweichenden Bogens erhält man gemäß Abbildung \ref{fig:gps_3_satelliten} ein krummliniges Fehlerdreieck, dessen Mittelpunkt der gesuchten Position entspricht. Analog zum 2-dimensionalen Fall benötigt man demzufolge im 3-dimensionalen Raum gemäß Abbildung \ref{fig:gps_4_satelliten} 4 Bögen beziehungsweise Satelliten.

Durch die Verwendung von \gls{DGPS} kann die Genauigkeit von \gls{GPS} gesteigert werden. Dabei werden Korrekturdaten für das Bahn- und Zeitsystem durch vorher vermessene, ortsfeste Referenzstationen ausgestrahlt und bei kompatiblen Empfängern zur Berechnung einbezogen.

Besitzt der Empfänger eine zusätzliche \gls{GPS}-Antenne, die in einem bekannten Abstand montiert ist, so können zusätzliche Winkelinformationen (das Heading) berechnet werden. Durch Auswertung der Phasenverschiebung und des Antennenabstandes wird der Winkel zwischen Antennenverbindungsachse zu den Ephemeriden des Satelliten sowie gegen die Nordrichtung bestimmt. Geräte dieser Kategorie bezeichnet man als elektronischer Kompass oder \gls{GPS}-Kompass.

##### Fehlerbetrachtung

Die Genauigkeit der Positionsbestimmung mittels \gls{GPS} unterliegt verschiedenen physikalischen und politischen Einflüssen.

###### Selective Availability

Bis zum 02. Mai 2000 wurde gemäß @The-National-Coordination-Office-for-Space-Based-Positioning-Navigation-and-Timing2013 durch die *selective availability* ein künstlicher Fehler zugeschaltet. Dabei wurde das Taktsignal einem Jitter (eine geringe zeitliche Schwankung) ausgesetzt. Dies resultiert in einem Fehler der Positionsbestimmung von mehreren 100 m.

###### Satellitengeometrie

Die Positionierung zwischen Empfänger zu den empfangenen Satelliten bezeichnet man als Satellitengeometrie. Befinden sich die Satelliten in hauptsächlich einer Richtung, vergrößert sich der Bereich der potenziellen Positionen des Empfängers. Dieses Problem tritt zum Beispiel bei konstanter Abschirmung der Signale aus einer bestimmten Richtung auf. Die Positionsbestimmung ist dabei entweder gar nicht oder nur auf bis zu 150 m möglich. Als *Güte* der Satellitengeometrie sind im Allgemeinen die \gls{DOP}-Werte (Verschlechterung der Genauigkeit) sehr verbreitet. Abhängig von den zur Berechnung herangezogenen Daten unterscheidet man gemäß Tabelle {@tbl:dop-werte} verschiedene Güte-Kategorien.

Table: Kategorien verschiedener DOP-Werte nach @Kohne2008. {#tbl:dop-werte}

| \gls{DOP}-Wert                            | Genauigkeit | herangezogene Daten   |
| :---                                      | :----       | :---                  |
| *Geometric Dilution Of Precision (GDOP)*  | Gesamt      | 3D-Koordinaten + Zeit |
| *Positional Dilution Of Precision (PDOP)* | Position    | 3D-Koordinaten        |
| *Horizontal Dilution Of Precision (HDOP)* | Horizontal  | 2D-Koordinaten        |
| *Vertical Dilution Of Precision (VDOP)*   | Vertikal    | Höhe                  |
| *Time Dilution Of Precision (TDOP)*       | Zeit        | Zeit                  |

###### Satellitenumlaufbahnen

Trotz regelmäßiger Korrektur der Ephemeridendaten durch das Kontrollsegment kommt es durch Gravitation von Sonne und Mond zu Bahnfehlern. Diese wirken sich mit einer Abweichung von circa zwei Metern auf die Genauigkeit der Positionsbestimmung aus.

###### Mehrwegeausbreitung

Durch lokale Abschirmung unter Bäumen, unter Brücken, in oder zwischen Gebäuden wird zudem das Satellitensignal gestört, geblockt oder gelangt durch Mehrwegeausbreitung zum Empfänger. Die reflektierten Signale legen eine längere Strecke als Signale im Direktweg zurück und kommen zeitlich versetzt am Empfänger an. Durch Reflexionen ändert sich die Polarisation des Satellitensignals, sodass der Effekt durch eine geeignete Konstruktion der Antennen minimiert werden kann.

###### Atmosphärische Eigenschaften

Einen weiteren Einfluss auf die Genauigkeit hat der Zustand der Ionosphäre und der Troposphäre. Je nach Elevationswinkel des Satelliten wird eine größere Strecke durch die Schichten der Atmosphäre zurückgelegt, was zum Beispiel Effekte der Refraktion verstärkt. Zusätzlich verursacht die Schwankungsbreite der Anzahl der freien Elektronen in der Ionosphäre einen Fehler von circa 30 m in der Positionsbestimmung. Durch Auswertung der 6 Ionosphärenparameter der Satelliten kann der Fehler auf unter 10 m reduziert werden. Durch die Verwendung zweier unterschiedlicher Frequenzen zur Übertragung der Satellitensignale kann zudem die Einwirkung der Atmosphäre herausgerechnet werden.

###### Zeitungenauigkeiten und Rundungsfehler

Trotz Synchronisation der Uhr des Empfängers bleibt die Ungenauigkeit der Satellitenuhr. Durch zusätzliche Rundungsfehler im Empfänger steigt diese Ungenauigkeit um 1 - 3 m.

Zusammenfassend kann man sagen, dass die Bestimmung der Position mittels \gls{GPS} bis zu circa 12 m genau ist. Durch die Verwendung von \gls{DGPS} wird die Genauigkeit auf 0,3 - 2,5 m für die Position ($x$, $y$) und 0,2 - 5 m für die Höhe gesteigert. Durch die zusätzliche Auswertung der Phasenverschiebung kann die Genauigkeit auf 1 - 10 mm pro km Abstand zur Referenzanlage verbessert werden.

Durch die Verwendung einer sogenannten \gls{RTK}-Lösung werden Positionsdaten zwischen einer Referenzantenne zur bewegten Antenne (Rover) mittels einer Mobilfunkverbindung übertragen. Diese Daten ermöglichen eine Positionsgenauigkeit ($x$, $y$) von 1 - 2 cm und einer Höhengenauigkeit von circa 2 - 3 cm.

#### Bestimmung von Lage und Ausrichtung durch Inertiale Messeinheiten

Inertialsensoren messen anhand der Trägheit von intern verbauten, quantitativ bekannten Massen die durch eine Bewegung einwirkende Beschleunigung und Drehrate. Durch die Kombination mehrerer Inertialsensoren in einer \gls{IMU} können so die Bewegungen in allen \gls{6DoF} bestimmt werden.

##### Aufbau

Grundsätzlich besteht eine \gls{IMU} aus Beschleunigungs- und Drehratensensoren. Die Beschleunigungssensoren messen die Beschleunigung entlang 3 orthogonal zueinander stehenden Hauptachsen $x$, $y$ und $z$. Durch die Drehratensensoren können zudem die Rotationen um diese Hauptachsen gemessen werden.

Ursprünglich verwendete man seismische Massen. Eine seismische Masse bezeichnet eine in der Messachse beweglich aufgehängte träge Masse. Auf Grund der Massenträgheit wurden die Bewegungsänderungen der Massen gemessen. In Folge der Miniaturisierung verwendet man heutzutage sogenannte \gls{MEMS}. Dabei handelt es sich um gefedert aufgehängte Siliziumstege im $\mu$m Bereich. Bei einer Beschleunigung werden die Stege ausgelenkt, was in der Änderung der elektrischen Kapazität zu einer festen Bezugselektrode messbar ist.

##### Funktionsweise

Inertialsensoren bestimmen den Betrag und die Richtung der Beschleunigung $a(t)$ eines Massepunktes $m$ im Raum. Gemäß des zweiten Newtonschen Gesetzes (Gleichung (@eq:zweites_newtonsches_gesetz)) wird bei festgelegten Anfangsbedingungen durch einfache Integration über die Zeit die Geschwindigkeit $v(t)$ bestimmt. Durch die zweifache Integration erhält man die Positionsänderung $s(t)$.

$$ \sum_J{F^J} = m * a(t) = m * \frac{\partial v}{\partial t} = m * \frac{\partial^2 s}{\partial t^2} $$ {#eq:zweites_newtonsches_gesetz}

Sind die Anfangsgeschwindigkeit sowie der Ausgangspunkt bekannt, so folgt durch die Integration ein absoluter Ort nach der Verschiebung des Sensors.

Durch Drehratensensoren wird die Winkelgeschwindigkeit entlang einer Drehachse gemessen. Die Winkelgeschwindigkeit kann dabei je nach verwendetem Medium anhand zweier Messprinzipien ermittelt werden:

- die auf ein mechanisch bewegtes System wirkende Corioliskraft und
- den Sagnac-Effekt bei optischen Systemen.

Die Corioliskraft bezeichnet gemäß @Kuchling2011 die Kraft, die auf einen sich bewegenden Körper auf einem rotierenden Bezugssystem wirkt. Der bewegte Körper beschreibt trotz radialer Bewegung (nach innen oder außen) eine Bahnkurve, die auf seiner Trägheit beruht.

Bei dem Sagnac-Effekt handelt es sich um die Beobachtung einer relativistischen Eigenschaft. Gemäß @Demtroder2013 wird bei einem Sagnac-Interferometer eine ebene Lichtwelle in zwei Teilwellen aufgeteilt, durch Spiegel um eine Fläche $A$ umgelenkt und anschließend wieder überlagert. Im Ruhezustand sind die Strecken für beide Teilwellen gleich lang, wodurch am Detektor die maximale Intensität gemessen wird. Rotiert man nun das gesamte Interferometer, verlängert sich die zurückzulegende Strecke für eine Teilwelle, für die andere verkürzt sie sich. Das Resultat ist eine Phasendifferenz $\Delta\phi$ zwischen den beiden Teilwellen und eine Änderung in der Intensität $I$ im Überlagerungsgebiet.

Gemäß Gleichung {@eq:intensitaet_nach_sagnac} ist die zu messende Intensität $I(\Delta\phi)$ abhängig von der Phasendifferenz $\Delta\phi$.

$$ I(\Delta\phi) = \frac{1}{2} * I_0 * (1 + \cos{\Delta\phi}) $$ {#eq:intensitaet_nach_sagnac}

Die Phasendifferenz wiederum ist gemäß Gleichung {@eq:phasendifferenz} abhängig vom Winkel zwischen der Flächennormalen und der Drehachse $\Theta$, der Kreisfrequenz der Drehung $\Omega$, der zu umlaufenden Fläche $A$ und der Wellenlänge des verwendeten Lichts $\lambda$.

$$ \Delta\phi = \frac{8 * \pi * A}{c * \lambda} * \Omega * \cos{\Theta} $$ {#eq:phasendifferenz}

Durch das Experiment von @Michelson1925 konnte mit dem Sagnac-Interferometer die Rotation der Erde nachgewiesen werden. Laser-Kreisel bieten heutzutage bereits auf kleineren Flächen die Möglichkeit, Rotationen mithilfe des Sagnac-Effekts zu messen. Aus messtechnischen Gründen wurde das Messverfahren abgewandelt.

Durch die Interferenz von Teilauskopplungen beider Strahlen kann man eine Differenzfrequenz als Schwebung beobachten, das heißt, die Interferenzstreifen wandern je nach Drehrichtung nach links oder rechts. Durch Messung der Amplitudenmodulation der interferierenden Strahlen mit einer Fotodiode kann die Differenzfrequenz der Strahlen berechnet werden.

##### Fehlerbetrachtung

Der größte Fehler bei einer \gls{IMU} entsteht durch den sogenannten Kreiseldrift. Mechanische Unwuchten am Kreisel führen zu einem unvermeidlichen Drift des Kreisels. Diese Unwuchten im Rotor (Kreiselkörper) haben teilweise ihren Ursprung in Fertigungstoleranzen und sind abhängig von der Umgebung des Kreisels.

###### Präzession

Wirkt eine mechanische Kraft ein senkrechtes Drehmoment auf die Rotationsachse des Rotors aus, so wird die Kreiselachse abgelenkt, es kommt zur Präzession.

###### Nutation

Wirkt ein Impuls auf einen rotierenden Kreisel, der nicht parallel zum minimalen oder maximalen Trägheitsmoment ausgerichtet ist, vollführt der Kreisel eine Nickbewegung. Diese Nickbewegung bezeichnet man als Nutation.

Durch Schwankungen der Temperatur, Wechselwirkungen mit den Beschleunigungssensoren, Lagerreibung oder mechanische Stöße sowie Vibrationen wird die Messung zudem erschwert.

Bei der Verwendung von Laser-Kreiseln kommt es zu einem weiteren Fehler, der als Lock-In-Effekt bezeichnet wird. An jedem Spiegel treten neben der Reflexion und Transmission auch Streuung auf, wodurch ein gewisser Teil des gestreuten Lichts entgegen der Umlaufrichtung eingekoppelt wird. Bei kleinen Drehraten resultiert daraus, dass beide Laserschwingungen die gleiche Frequenz haben. Dieser lineare Fehler ist abhängig von der Stärke der Streuung, die durch Staubteilchen und Temperaturschwankungen im System gesteigert wird.

Es ist zu erkennen, dass der Großteil der Fehler einer \gls{IMU} konstruktionsbedingt ist. Nach @Edwan2013 unterteilt man \gls{IMU}'s gemäß den Tabellen @tbl:drehraten_kategorien und @tbl:acc_kategorien in die Produktkategorien, in denen sie hauptsächlich verwendet werden. Die Kategorisierung ist dabei abhängig von der Genauigkeit, die für die Anwendung gefordert wird.

Table: Kategorisierung von Drehratensensoren in Inertialen Messeinheiten. {#tbl:drehraten_kategorien}

| Kategorie | Bias Stabilität $\left[\frac{^\circ}{h}\right]$ | Skalierungsfaktor $\left[PPM\right]$ | Grundrauschen $\left[\frac{^\circ}{\frac{h}{\sqrt{Hz}}}\right]$ |
| :----     | :-----                                          | :-----                               | :----                                                           |
| **Consumer**      | $>200$   | $-$       | $180$      |
| **Automotive**    | $10-200$ | $>500$    | $180$      |
| **Tactical**      | $1-10$   | $200-500$ | $12-30$    |
| **Navigation I**  | $0.1-10$ | $100-200$ | $3-12$     |
| **Navigation II** | $<0.01$  | $5-50$    | $0.12-0.3$ |

Table: Kategorisierung von Beschleunigungssensoren in Inertialen Messeinheiten. {#tbl:acc_kategorien}

| Kategorie | Bias Stabilität $\left[\mu g\right]$ | Skalierungsfaktor $\left[PPM\right]$ | Grundrauschen $\left[\frac{\mu g}{\sqrt{Hz}}\right]$ |
| :----     | :-----                               | :-----                               | :----                                                |
| **Consumer**      | $2400$    | $-$        | $1000$    |
| **Automotive**    | $1200$    | $>1000$    | $1000$    |
| **Tactical**      | $200-500$ | $400-1000$ | $200-400$ |
| **Navigation I**  | $50-100$  | $100-200$  | $50$      |
| **Navigation II** | $5-10$    | $10-20$    | $5-10$    |

#### Verbesserung der Genauigkeit durch Koppelnavigation

Koppelnavigation bezeichnet die kontinuierliche Ortsbestimmung eines bewegten Objekts auf Grund der Bewegungsrichtung (Kurs) und Geschwindigkeit (Fahrt). Durch die Kombination von \gls{GPS} und einer \gls{IMU} werden die Vor- und Nachteile der einzelnen Systeme ausgeglichen und eine kontinuierliche Bestimmung der Pose ermöglicht.

Zum Einschaltzeitpunkt ermöglicht das \gls{GPS} auf Grund von veralteten Ephemeriden keine absolute Positionsbestimmung, durch die Verwendung der \gls{IMU} kann jedoch eine relative Positionsbestimmung durch Bewegung durchgeführt werden. Das \gls{GPS} bietet sekündlich neue Positionsinformationen, während dazwischen mit Hilfe der \gls{IMU} die Position interpoliert wird.

Durch den unvermeidlichen Drift eines Kreisels weicht der gemessene Kurs vom realen Kurs über die Zeit ab. Heutige Kreiselsysteme bieten einen minimalen Drift von circa $0.01^\circ$ pro Stunde. Auf Grund dieser Abweichung rechnet man mit einer Abweichung von 1 Seemeile pro Stunde. Durch die regelmäßige Positionsinformation durch das \gls{GPS} kann der Drift der \gls{IMU} in regelmäßigen zeitlichen Abständen korrigiert werden.

Zur Kopplung der Sensordaten werden gemäß @Benzerrouk2013 Kalman-Filter verwendet. Ein Kalman-Filter ist dabei ein Satz mathematischer Gleichungen, mit denen Störungen, die durch Messgeräte entstehen, entfernt werden. Der Kalman-Filter ist dabei auf die Messfehler und auf die mathematische Struktur des zugrundeliegenden dynamischen Systems angepasst. Diese Kombination aus optimierten \gls{GPS}- und \gls{IMU}-Sensordaten wird im Folgenden als \glspl{NAV}-Lösung beziehungsweise \gls{NAV}-Sensorik bezeichnet.

## Datenstrukturen

Datenstrukturen dienen der geordneten Speicherung von einzelnen vorliegenden Daten in einer zusammenhängenden Struktur. Dadurch können die Daten in einem gemeinsamen Zusammenhang verglichen und je nach Implementierung effizient auf Speicherbereiche aufgeteilt werden. Für die vorliegende Arbeit werden Datenstrukturen wie Punkte, Punktwolken und Suchbäume aus der \gls{PCL} verwendet und erweitert.

Die \gls{PCL}^[@Rusu2011.] beinhaltet verschiedene Algorithmen zur Filterung, Feature-Bestimmung, Oberflächen-Rekonstruktion, Registrierung, Modell-Anpassungen und Segmentierung von Punktwolken. Durch die Verwendung der Bibliotheken Boost^[@Dawes1998.], FLANN^[@Muja2008, @Muja2012, @Muja2014.], Eigen^[@Guennebaud2010.] und VTK^[@Schroeder2004.] werden zudem verschiedene mathematische Operationen und Möglichkeiten zur Visualisierung der Punktwolken zur Verfügung gestellt.

### Punkte

Punkte bezeichnen die kleinste Datenstruktur und repräsentieren zum Beispiel eine mehrdimensionale Position oder eine Eigenschaft an einer bestimmten Stelle des Messraumes. Gemäß @Delmerico2013 bietet die \gls{PCL} verschiedene standardmäßig implementierte Typen von Punkten. Punkte bieten somit die Möglichkeit, Koordinaten, Farbinformationen, Normalenvektoren oder Intensitätswerte zu speichern. Für die Verwendung im \gls{DIP} wurde eine eigene Punkt-Klasse angelegt, die neben den Koordinaten $x$, $y$ und $z$ auch die Speicherung des Normalenvektors sowie einer Ursprungskoordinate ermöglicht. Da die Position des Sensors während der Aufnahme eines Scans nicht konstant ist, wird die Position des Sensors zum Zeitpunkt der Aufnahme des Messpunktes als Ursprungskoordinate gespeichert. Dadurch ist es möglich, die Bewegung des Sensors bei der Verortung der Messpunkte zu berücksichtigen.

### Punktwolken

Eine Punktwolke dient der Repräsentation einer Zusammenstellung von mehreren Punkten. Punktwolken werden meist durch Sensoren wie \gls{RGB-D}-Kameras, Stereokameras, \gls{LiDAR}-Sensor, \gls{ToF}-Kameras oder durch Software wie Blender generiert. Gemäß den implementierten Punktwolken in der \gls{PCL} bestehen Punktwolken aus einem Vektor von Punkten, einer Breite (`width`), einer Höhe (`height`) sowie den Parametern `is_dense`, `sensor_orientation` und `sensor_origin`. Handelt es sich bei der vorliegenden Punktwolke um organisierte Daten, so entspricht die Breite der Zahl der Spalten und die Höhe der Zahl der Zeilen. Bei unorganisierten Daten entspricht die Breite der Anzahl an Punkten in der Punktwolke und die Höhe hat den Wert "1".

Enthält die Punktwolke nur finite Messwerte, also keine `NaN`^[In der Informationstechnik bezeichnet `NaN` (Not a Number) einen numerischen Datentyp-Wert, der einem undefinierten oder nicht darstellbaren Wert entspricht.] oder `Inf`^[`Inf` (Infinity) bezeichnet die Darstellung der Unendlichkeit eines Wertes.], so ist der Wert `is_dense` wahr. Die Eigenschaften `sensor_orientation` und `sensor_origin` können als Parameter für den Sensor verwendet werden, was jedoch nur im stationären Zustand während der Aufnahme der Punktwolke Anwendung findet.

### Suchbäume \label{suchbaeume}

Um mehrere Punktwolken effizient miteinander zu vergleichen, werden die Punkte in sogenannten Suchbäumen abgespeichert. Ein Suchbaum wird dabei entsprechend eines Schemas aufgebaut und ist abhängig von der darauf anzuwendenden Suchstrategie. Für den \gls{ICP}-Algorithmus werden die Punktwolken iterativ anhand der nächsten Nachbarn der einzelnen Punkte registriert. Um diese Suche zu optimieren, werden die Punkte in einem $k$d-Baum gespeichert. Gemäß @Bentley1975 ist ein $k$d-Baum ein mehrdimensionaler ($k$-dimensional) Binärbaum. Ein $k$d-Baum ermöglicht somit die orthogonale Bereichsanfrage, wie sie zum Beispiel bei der Suche nach den nächsten Nachbarn eines Punktes vorliegt.

## Bezugssysteme

Das \gls{DLR} erforscht die Verwendung von \gls{LiDAR}-Sensoren zur Erstellung digitaler Karten und als Grundlage zur automatisierten Navigation. Dabei werden Navigationssensoren eingesetzt, die eine Bestimmung der Lage und Position im 3-dimensionalen Raum ermöglichen. Zur Verarbeitung der Sensordaten werden unterschiedliche Bezugssysteme verwendet. Dabei handelt es sich um  kartesische Koordinatensysteme, die unterschiedlich ausgerichtet und positioniert sind.

### Sensor

Jeder Sensor misst eine physikalische Eigenschaft in einem speziellen, dafür vorgesehen Koordinatensystem. Bei einem \gls{NAV}-Sensor ist dies eine zeitliche Abfolge von Positions- und Lagevektoren. Bildgebende Sensoren wie \gls{LiDAR}-Sensoren speichern ihre Messdaten in polaren Kugelkoordinaten ab. Die Kugelkoordinaten werden in ein kartesisches Koordinatensystem überführt und als \gls{PCL}-Punktwolken gespeichert.

### Träger

Die Sensoren sind auf sogenannten Trägern montiert. Je nach Konstruktion kann ein \gls{UA} mehrere Träger transportieren. In der vorliegenden Arbeit befinden sich die verwendeten bildgebenden und \gls{NAV}-Sensoren auf einem gemeinsamen Träger, der fest mit dem \gls{UA} verbunden ist (nicht beweglich). In diesem Fall entspricht die Bewegung des Trägers auch der Bewegung des \gls{UA}. Die \gls{NAV}-Sensoren befinden sich im Massenschwerpunkt des \gls{UA}. Dadurch kann die Bewegung des \gls{UA} in alle Richtungen gleichmäßig gemessen werden. Das Trägerbezugssystem hat seinen Ursprung im Massenschwerpunkt des Trägers und ist gemäß dem \gls{NED}-Standard ausgerichtet. Gemäß Abbildung @fig:ned zeigt die $x$-Achse in Hauptflugrichtung entlang der Längsachse des \gls{UA}, die $y$-Achse orthogonal nach rechts und die $z$-Achse nach unten. Alle Rotationen werden gemäß der \glspl{DIN} 9300 (siehe Tabelle @tbl:bezeichnung_der_winkel_gemaess_der_luftfahrt_din_9300) in der Reihenfolge $z$, $y^\prime$ und anschließend $x^{\prime\prime}$ durchgeführt. Dies entspricht der Konvention in der Luft- und Raumfahrt.^[In der Automobilbranche werden die Rotationen und Koordinatensysteme anders ausgerichtet. Dies ist in der \gls{DIN} 70000 erläutert.]

### Welt

Das Weltbezugssystem wird unterschieden in ein relatives und ein absolutes Bezugssystem. Das relative betrachtet die Position des Trägers von der Startposition aus, die mit $(0, 0, 0)$ initialisiert wird. Das absolute Bezugssystem entspricht dem \gls{WGS84} nach dem \gls{ECEF}, wobei die Startposition mit der zum Start befindlichen Position in Längen- und Breitengraden initialisiert wird.

![Darstellung der verschiedenen Bezugssysteme (@Andert2011)](Images/reference_frames.pdf) {#fig:ned}

Da das Sensorbezugssystem keinen Bezug zu einer Posenänderung hat, kann eine digitale Karte nur im Träger- oder Weltbezugssystem erstellt werden. Damit die aufgenommenen Punktwolken korrekt in die Karte eingetragen werden können, müssen sie in das entsprechende Bezugssystem transformiert werden. Diese Transformation ist abhängig von der Montagepose des \gls{LiDAR} in Relation zur \gls{IMU} und wird bisher durch eine manuelle extrinsische Kalibrierung bestimmt.

# Relative extrinsische Kalibrierung von bildgebenden Umweltsensoren

Für die Erstellung einer Karte wird ein bildgebender Sensor benötigt, der die Umgebung vermisst. Zur Vermessung eines Gebietes muss dieser Sensor über das Gebiet bewegt werden. Dafür wird der Sensor an einem \gls{UA} angebracht. Damit die Messungen korrekt in eine Karte überführt werden können, müssen sie mit der Bewegung des \gls{UA} in Verbindung gebracht werden. Dafür wird eine \gls{NAV}-Sensorik eingesetzt, die die Bewegung des \gls{UA} kontinuierlich aufzeichnet. Aus konstruktionstechnischen Gründen befindet sich die \gls{NAV}-Sensorik an einer anderen Position des \gls{UA} und in unterschiedlicher Ausrichtung als der bildgebende Sensor. Dieser Unterschied in Position und Lage wird als Montagepose bezeichnet.

![Ablauf der Kartografie von Punktwolken](Images/kartografie_der_laserscans.pdf) {#fig:ablauf_der_kartografie}

Die aufgenommenen Laserscans der Umgebung werden nun gemäß Abbildung @fig:ablauf_der_kartografie mit der Montagepose vom Sensorbezugssystem des bildgebenden Sensors in das Trägerbezugssystem transformiert. Nun können die Laserscans durch Transformation mit den Navigationsdaten der \gls{NAV}-Sensorik vom Trägerbezugssystem in das Weltbezugssystem überführt werden. Durch kontinuierliche Speicherung der aufgenommenen Messungen der Umgebung, die sich nun im Weltbezugssystem befinden, kann eine Karte erstellt werden. Abbildung \ref{fig:gegenueberstallung_einzelner_laserscan_zu_karte} zeigt eine Gegenüberstellung von einem einzelnen Laserscan \ref{fig:laserscan_single} und seiner Überführung in eine Karte \ref{fig:laserscan_scene}.

\begin{figure}[h!]
    \centering
    \subcaptionbox{Einzelner Laserscan\label{fig:laserscan_single}}
        [.5\linewidth]
        {\includegraphics[width=.5\linewidth]{Images/laserscan_single.png}}%
    \subcaptionbox{Laserscan zu einer Karte hinzugefügt\label{fig:laserscan_scene}}
        [.5\linewidth]
        {\includegraphics[width=.5\linewidth]{Images/laserscan_scene.png}}%
    \caption{Gegenüberstellung von einem einzelnen Laserscan und seiner Überführung in eine Karte}
    \label{fig:gegenueberstallung_einzelner_laserscan_zu_karte}
\end{figure}

Eine fehlerhafte oder ungenaue Angabe der Montagepose führt dazu, dass die Karte falsch aufgebaut wird. Aus diesem Grund wird in den folgenden Abschnitten eine automatisierte relative extrinsische Kalibrierung vorgestellt, die eine korrekte Bestimmung der Montagepose ermöglicht.

## Forschungsstand

Zu diesem Zeitpunkt ist nur die Arbeit von @Levinson2011 über eine automatisierte extrinsische Kalibrierung von \gls{LiDAR}-Sensoren bekannt. Er beschreibt eine intrinsische sowie eine extrinsische Kalibrierung von \gls{LiDAR}-Sensorn für ein autonomes Fahrzeug, wobei die präsentierte Lösung auf der Auswertung der einzelnen Laserstrahlen basiert. Er setzt voraus, dass die Echos benachbarter Laserstrahlen auf das gleiche Hindernis in der realen Welt treffen. Bei höheren Fahrzeuggeschwindigkeiten und dynamischeren Bewegungen scheitert das vorgestellte Verfahren. Des Weiteren ist diese Art der extrinisischen Kalibrierung stark auf den verwendeten \gls{LiDAR}-Sensor zugeschnitten und nicht allgemein anwendbar.

Bisher wurde die extrinsische Kalibrierung von \gls{LiDAR}-Sensorn zu \glspl{IMU} anhand fest definierter *Features*^[Features bezeichnet eindeutig erkennbare und unterscheidbare Merkmale in aufgenommenen Bildern.] unter anderem durch @Talaya2004 vorgenommen. Dabei wurden Häuserwände vermessen, deren \gls{NAVSTAR-GPS}-Positionen bestimmt und mit reflektierenden Materialien beklebt. Die reflektierenden Materialien konnten im Anschluss auf Grund einer höheren Intensität beim Laserscan extrahiert werden. Durch die Analyse der bekannten \gls{NAVSTAR-GPS}-Positionen und den gemessenen Positionen im Laserscan mit höheren Intensitäten konnten Rückschlüsse auf die Montagepose des \gls{LiDAR}-Sensors gezogen werden. Das Verfahren basiert auf der Erkennung von planaren Features. Eine mathematische Lösung für dieses Verfahren zeigten @Bae2007, die die Abstände zwischen Scanpunkten zu einer möglichen zugehörigen Fläche minimierten.

Für den Fall, dass keine planaren Flächen zur Verfügung stehen, präsentiert @Chan2015 einen Ansatz, der zylinderförmige Features aus Laserscans zur Kalibrierung verwendet. Dabei wurde die Annahme getroffen, dass in urbanem Gelände häufig Zylinder in Form von Rohren auftauchen, deren Ausrichtung meist horizontal oder vertikal ist. Zur Validierung ihres Ansatzes untersuchten sie verschiedene Ausrichtungen der Zylinder und unterschiedliche Montagepositionen des \gls{LiDAR}-Sensors. Ihr Ansatz scheiterte, wenn sich mehrere unterschiedlich ausgerichtete Zylinder in der zu detektierenden Umgebung befanden.

Natürliche Umgebungen weisen kaum planare oder zylinderförmige Formen auf, sodass diese Ansätze nur in urbanem Gelände Anwendung finden können. @Sheehan2011 und @Maddern2012 identifizierten Scannerparameter anhand eines Maßes der Vielfältigkeit von Punktwolken (Rényi Quadratic Entropy). Ihr Hauptaugenmerk lag dabei auf der Synchronisation mehrerer \gls{LiDAR}-Sensor zueinander um detailreiche Umgebungsscans zu generieren. Des Weiteren befinden sich die Scanner zwar in einer rotatorischen Bewegung, jedoch translatorisch in einem stationären Zustand.

Des Weiteren ist in der Literatur der \gls{SLAM}-Algorithmus bekannt. \gls{SLAM} bezeichnet die Korrektur von Sensordaten anhand einer kontinuierlichen Kartenerstellung.^[Im Automobilbereich werden zur Verfolgung der Bewegung sogenannte Odometriesensoren verwendet, die zum Beispiel die Umdrehungen der Räder zählen. Durch Schlupf auf Grund unterschiedlicher Luftdrücke der Räder, wechselndem Beladezustand oder variierendem Untergrund, sind diese Messdaten sehr fehlerbehaftet. Durch die Erstellung einer Karte und einem *Loop-Closing*-Pfad (es wird eine zyklische Strecke abgefahren) werden die Sensorwerte entsprechend korrigiert.]

@Davison2007 präsentierten einen \gls{SLAM} Ansatz, um mehrere Kamerabilder bei schnellen Bewegungen zu einer spärlichen Landkarte zusammenzufügen. Sie verwendeten dafür ein probabilistisches Feature-basiertes Kartenmodell und ein allgemeines Bewegungsmodell einer Kamera. Informationen über die Entfernungen wurden durch die Features definiert. Einen Ansatz zur Generierung von 3D-Landkarten mit Entfernungsinformationen bietet @May2008. Der Ansatz verwendete \gls{ToF}-Kameras und einen Roboter, der für jede Aufnahme stoppt, wodurch stabile Punktwolken generiert werden können.

Bisherige Entwicklungen am \gls{DLR} beschreiben gemäß @Stellmacher2014 die Registrierung von Punktwolken auf Basis eines OcTrees (eine effiziente Baumstruktur, um dreidimensionale Datensätze hierarchisch zu gliedern). Das Ziel seiner Arbeit war eine Optimierung der Aneinanderreihung der Punktwolken in Echtzeit^[Echtzeit bezeichnet in diesem Zusammenhang die Bedingung, dass die Punktwolken schneller zueinander registriert werden können, als neue Sensordaten vorliegen.]. Das Resultat ist eine minimale Verbesserung der Registrierung, jedoch konnte die Echtzeitbedingung nur unter Einschränkungen eingehalten werden.

Des Weiteren werden bereits gemäß @Krause2012 erfolgreich Feature-basierte Kalibrierungen zwischen \gls{LiDAR}-Sensoren und Kameras eingesetzt. Grundlage für diese Forschungen ist unter anderem die Arbeit von @Andert2011.

## Ansatz zur Kalibrierung

Für die relative extrinsische Kalibrierung des bildgebenden Sensors zur \gls{NAV}-Sensorik werden folgende Anforderungen definiert: (1) die Umgebung wird als unveränderlich und starr angenommen, (2) die zu vermessende Bewegung muss größer als die größte Messungenauigkeit des Systems sein, (3) die Position der Sensoren zueinander ist während der Kalibrierung unveränderlich und (4) der Träger ist fest mit dem \gls{UA} verbunden, sodass die Bewegung des \gls{UA} direkt der Bewegung des Trägers entspricht.

Die Grundlage der Kalibrierung bilden die Aufnahme von Umgebungsscans durch bildgebende Sensoren und die gleichzeitige Verfolgung der Bewegung durch eine \gls{NAV}-Sensorik, bestehend aus einer \gls{6DoF}-\gls{IMU} und einem \gls{GPS}.

\begin{figure}[hbtp!]
    \centering
      \includegraphics[width=.6\linewidth]{Images/bewegungskorrektur}
      \caption{Veränderung des Bildbereichs, wenn die Bewegung des Trägers (von $P_1$ nach $P_5$) schneller als die Aufnahmefrequenz des Sensors ist (schematische Darstellung)}
        \label{fig:bewegungskorrektur}
\end{figure}

Die Erstellung der Umgebungsscans erfolgt durch scannende \gls{LiDAR}-Sensoren, die für jeden Scan eine 3-dimensionale Punktwolke in Form von Entfernungsmessungen generieren. Die Punktwolken werden dabei in einer festen Taktrate, die abhängig vom verwendeten \gls{LiDAR}-Sensor ist, generiert. Aus aufeinanderfolgenden Umgebungsscans wird die Differenz anhand eines \gls{ICP}-Algorithmus berechnet und in Form einer Transformationsmatrix gespeichert.Parallel werden die Bewegungen des \gls{UA} in Form von Positions- und Winkeländerungen gemessen. Die Taktrate für die Bewegungsmessung ist systembedingt höher als die der Erstellung der Umgebungsscans. Diese Bewegungen werden ebenfalls als Transformationsmatrix gespeichert.

Bei einem \gls{LiDAR}-Sensor handelt es sich um ein scannendes System. Dabei wird die Umgebung in zeitlich diskreten Schritten vermessen. Befindet sich der \gls{LiDAR} im Stillstand, kann die Umgebung korrekt vermessen werden. Wird der \gls{LiDAR} jedoch während der Aufnahme einer Messung bewegt, führt dies zu Verzerrungen.

Abbildung \ref{fig:bewegungskorrektur} zeigt die Auswirkung, wenn sich der Träger, in diesem Fall das \gls{UA}, in Bewegung befindet. Ist die Aufnahmefrequenz des \gls{LiDAR} zu gering, hat sich der Träger deutlich bewegt. Die soeben erstellte Punktwolke repräsentiert nun eine Umgebung, die auf Grund der Bewegung verzerrt wird. Um dies zu korrigieren, muss der Laserscan Strahl für Strahl an die zwischenzeitliche Position des Trägers angepasst werden. Diese Anpassung wird im Folgenden als Bewegungskorrektur bezeichnet und erfolgt durch Interpolation der \gls{NAV}-Daten. Während der Recherche wurden diesbezüglich zwei Strategien zur Kalibrierung erarbeitet.

![Kalibrierung im Weltkoordinatensystem](Images/kalibrierungImWC.pdf) {#fig:kalibrierung_im_weltkoordinatensystem}

Abbildung @fig:kalibrierung_im_weltkoordinatensystem zeigt das Ablaufdiagramm der relativen extrinsischen Kalibrierung ohne Bewegungskorrektur. Dabei werden alle Bewegungen des Trägers während der Generierung der Datenpakete des \gls{LiDAR} ignoriert. Dies führt dazu, dass die gemessenen Hits (ein Hit bezeichnet den Auftreffpunkt des Laserstrahls auf einem Objekt) je nach Geschwindigkeit des Trägers zu weit in der Hauptbewegungsrichtung verortet werden.

Das Diagramm zeigt eine Ausgangs- und eine Endpose. Dazwischen wurde eine Bewegungsänderung durchgeführt, die mittels der \gls{NAV}-Sensorik gemessen wurde. Die empfangenen Umgebungsscans befinden sich im Bezugssystem des Sensors und werden nach der Umwandlung von Kugelkoordinaten zu kartesischen Koordinaten in einer Punktwolkenstruktur gespeichert.

Durch Transformation mit der Montagepose (zu Beginn kann diese Pose durch den Benutzer gesetzt werden, andernfalls sind alle Komponenten "0") werden beide Punktwolken in das Trägerbezugssystem transformiert. Die Punktwolke, die zum Zeitpunkt der Endpose aufgenommen wurde, entspricht zeitgleich dem relativen Weltbezugssystem, da danach noch keine Bewegung stattgefunden hat. Die Punktwolke zur Ausgangspose wird hingegen mit der durch die \gls{NAV}-Sensorik gemessenen Bewegung in das relative Weltbezugssystem transformiert. Anschließend werden die beiden Punktwolken, die sich nun im relativen Weltbezugssystem befinden, dem \gls{ICP}-Algorithmus übergeben. Der \gls{ICP}-Algorithmus bestimmt, wie gut die zwei Punktwolken zueinander passen. Wurde die richtige Montagepose zwischen dem \gls{LiDAR} und der \gls{NAV}-Sensorik verwendet, sollten die Punktwolken perfekt übereinstimmen. Liefert der \gls{ICP}-Algorithmus hingegen eine Differenz zwischen den Punktwolken, so ist die ursprünglich übergebene Montagepose um diese Differenz falsch und muss angepasst werden.

![Kalibrierung im Weltkoordinatensystem mit Bewegungskorrektur](Images/kalibrierungImWCmitKorr.pdf) {#fig:kalibrierung_im_weltkoordinatensystem_mit_korr}

Abbildung @fig:kalibrierung_im_weltkoordinatensystem_mit_korr zeigt den Ablauf der Kalibrierung mit Bewegungskorrektur. Der Unterschied zum vorherigen Diagramm ist die zusätzliche Transformation der einzelnen Umgebungsscans unter Verwendung der \gls{NAV}-Daten. da der \gls{LiDAR}-Sensor jedoch eine andere Montagepose als die \gls{NAV}-Sensorik aufweist, ist die gemessene Bewegung der \gls{NAV}-Sensorik zur tatsächlichen Bewegung des \gls{LiDAR}-Sensors unterschiedlich.

Eine Möglichkeit zur Korrektur wäre die Anpassung der \gls{NAV}-Daten auf die initial vorgegebene Montagepose, die jedoch ebenfalls fehlerbehaftet ist. Im Allgemeinen weist diese Methode einen zusätzlichen Berechnungsschritt für jede Punktwolke durch die Transformation auf. In der aktuellen Implementierung wird die Bewegung des Trägers berücksichtigt.

## Bewegungsextraktion aus aufeinanderfolgenden Punktwolken

Eine Grundlage für die Kalibrierung ist die Schätzung der Bewegung zwischen zwei Punktwolken.

### Registrierung von Punktwolken

Die Registrierung von Punktwolken erfolgt durch die Implementierung des \gls{ICP}-Algorithmus der \gls{PCL} gemäß @Besl1992. Dabei ist das Modell, das die Punktwolke repräsentiert, unabhängig für die Registrierung. Das Ziel des \gls{ICP} ist die Transformation zwischen zwei vorliegenden Punktwolken anhand der Fehlermetrik gemäß (@eq:fehlermetrik_icp).

$$ d(\vec{p}, X) = \min_{\vec{x} \in X} || \vec{x} - \vec{p} || $$ {#eq:fehlermetrik_icp}

Dabei bezeichnet $d$ die Distanz-Metrik zwischen einem beliebigen Punkt $\vec{p}$ der Datenmenge $P$ und der anzugleichenden Datenmenge $X$. Der Punkt in $X$, der die kleinste Distanz zu $\vec{p}$ hat, wird als $\vec{y}$ bezeichnet. $Y$ bezeichnet anschließend das Set aus nächsten Nachbarn durch den Operator $C$ und wird gemäß (@eq:set_of_nearest_neighbours) berechnet.

$$ Y = C(P, X)$$ {#eq:set_of_nearest_neighbours}

Der Algorithmus unterteilt sich dabei in 3 Schritte:

1. Berechne die nächsten Nachbarn für $Y_k = C(P_k, X)$
2. Berechne die Transformation zwischen $P_0$ und $Y_k$
3. Wende die Transformation auf $P_0$ an

Diese Schritte werden solange wiederholt, bis der Algorithmus terminiert. Dies ist der Fall, wenn (a) die Anzahl der Iterationen ein vom Benutzer angegebenes Maximum erreicht, (b) die Differenz zwischen der aktuellen geschätzten und der vorherigen Transformation $\epsilon$ kleiner als die vom Benutzer angegebenen Grenze ist (die Transformation wurde nur minimal besser) oder (c) die Summe des euklidischen quadratischen Fehlers kleiner als der vom Benutzer angegebene Fehlerbereich ist (die Transformation ist ausreichend genau).

Zur Beschleunigung der Berechnung können die Punktwolken nach unterschiedlichen Aspekten gefiltert und Features extrahiert werden.

### Extraktion von Features

Für die Registrierung von Punktwolken müssen Punkte miteinander verglichen werden. Punkte werden in einer Punktwolke in Form von kartesischen Koordinaten gespeichert. Vergleicht man nur die kartesischen Koordinaten zweier Punktwolken miteinander, besteht die Gefahr, dass zwei Punkte, die zu unterschiedlichen Zeiten aufgenommen wurden, die gleichen Koordinaten vorweisen, jedoch von unterschiedlichen Oberflächen stammen.

@Rusu2011 führt das Konzept der *point feature representations* (auch als *local descriptors*, *shape descriptors* und *geometric features* in der Literatur bekannt) ein.

Durch Zusammenfassung mehrerer Punkte in einer Nachbarschaft kann die Geometrie der Oberfläche erfasst und als *feature* formuliert werden. Im Idealfall sind die so definierten *features* zu einem gewissen Grad ähnlich zu anderen Punkten auf der gleichen oder einer ähnlichen Oberfläche.

Eine gute Repräsentation von *features* zeichnet sich dadurch aus, dass es möglich ist, sie unter Einwirkung einer Transformation in Form von Rotationen und Translationen, trotz unterschiedlich stark aufgelöster Punktwolken und der Existenz von Messfehlern identifizieren zu können.

Durch die Bestimmung von Keypoints kann der Berechnungsaufwand von Features im Vorhinein minimiert werden, da der Suchraum eingeschränkt wird. Ebenfalls wird damit verhindert, dass beim späteren Matching Fehler durch Nicht-Schlüsselpunkte verursacht werden.

#### Bestimmung von Keypoints

Punkte, die in irgendeiner Weise als relevant identifiziert werden, bezeichnet man als Keypoints (Schlüsselpunkte). Sie besitzen dabei folgende Eigenschaften:

- *Sparseness* (nur eine kleine Auswahl an Punkten aus der Gesamtmenge kommt in Frage),
- *Repeatability* (die identifizierten Punkte sind auch in ähnlichen Punktwolken an der entsprechenden Position zu finden),
- *Distinctiveness* (die Umgebung rund um den Schlüsselpunkt weist eine eindeutige Form oder Erscheinung auf).

Zur Identifikation von Keypoints werden die Punkte einer Punktwolke gemäß ihrer nächsten Nachbarn sortiert. Dafür werden in der \gls{PCL} die $k$d-Suchbäume gemäß Abschnitt \ref{suchbaeume} verwendet. Im Anschluss besteht die Möglichkeit, die Punktmenge nach einer festen Anzahl an Nachbarn für einen Punkt zu durchsuchen oder alle benachbarten Punkte in einem Radius $r$ zu betrachten.

#### Skaleninvariante Merkmalstransformation (SIFT)

\gls{SIFT} bezeichnet gemäß @Lowe1999 einen Algorithmus zur Detektion und Beschreibung lokaler Merkmale, die in gewissen Grenzen invariant gegenüber Koordinatentransformationen wie Translation, Rotation und Skalierung sind.

Der Algorithmus ist dabei in fünf Aufgaben unterteilt: (1) Feature-Detektion, (2) Feature-Matching und Indizierung, (3) Identifizierung von Clustern anhand eines *Hough transform*-Votings, (4) Überprüfung des Modells durch die Methode der kleinsten Quadrate und (5) Entfernung von Ausreißern.

Diese Variante ist die Grundlage für viele Optimierungen und wird bereits erfolgreich im Bereich der Bildverarbeitung eingesetzt.

#### (Fast) Point-Feature-Histogramm

Das Point-Feature-Historgramm ist eine Repräsentation der geometrischen Eigenschaften der benachbarten Punkte an einem Punkt. Dafür wird die mittlere Krümmung in Form eines mehrdimensionalen Histogramms von Werten generalisiert. Die Repräsentation eignet sich gut für unterschiedlich dichte Punktwolken und ist invariant gegenüber Änderungen des Betrachtungswinkels und Messfehlern.

Dafür werden die Oberflächen-Normalen der Umgebung geschätzt und die Variationen aller Interaktionen zwischen den Normalen extrahiert. Dieses Verfahren ist demzufolge stark von der Qualität der Normalen-Schätzung an jedem Punkt abhängig.

Die Filterfunktion ist sehr zeit- und rechenaufwendig, weswegen im Allgemeinen die *Fast*-Variante verwendet wird. Sie unterscheidet sich hauptsächlich darin, dass nicht alle Punkte miteinander verknüpft werden, sondern dass eine Gewichtung der Interaktionen durchgeführt wird.

#### Schätzung von Oberflächen-Normalen \label{schaetzung_von_oberflaechen_normalen}

Oberflächen-Normale sind eine wichtige Eigenschaft von geometrischen Oberflächen. Sie ermöglichen die Kombination von erkannten Oberflächen zu geometrischen Körpern, die speziell für die Erkennung von Hindernissen von Vorteil sind.

Für eine vorliegende Punktwolke können die Oberflächen-Normalen auf zwei Arten bestimmt werden: (a) durch die Erstellung von Meshs und anschließender Berechnung oder (b) durch Annäherung der Normalen einer Ebene an eine Oberfläche durch Minimierung der kleinsten Quadrate.

### Filterung der Daten

Filter dienen der Extraktion oder Anpassung von Daten. Für die vorliegende Arbeit werden verschiedene Filterfunktionen zum Anpassen des Messbereichs, der Minimierung der Punktmenge und der Korrektur von Messfehlern in Punktwolken vorgestellt.

#### Begrenzung des Messbereichs

Jeder \gls{LiDAR}-Sensor ist für einen bestimmten Messbereich ausgelegt. Messungen außerhalb dieses Messbereiches sind meist ungenau oder undefiniert. Messwerte, die sich unterhalb einer Mindest- und oberhalb einer Maximalentfernung befinden, können durch einen *Pass-Through*- oder auch Bandpass-Filter entfernt werden. Diese Filterfunktion entfernt Punkte, bei der es sich mit sehr hoher Wahrscheinlichkeit um fehlerbehaftete Messpunkte handelt.

Des Weiteren kann durch einen *Pass-Through*-Filter das \gls{FoV} verändert werden, wenn zum Beispiel ein bestimmter Bereich durch Elemente des Trägers verdeckt werden. Dies ist zum Beispiel der Fall, wenn der \gls{LiDAR}-Sensor an der Unterseite zwischen dem Fahrgestell montiert ist. Das Fahrgestell reflektiert die Laserstrahlung, sodass es vom \gls{LiDAR}-Sensor als Hindernis detektiert wird. Da sich das Fahrgestell jedoch dauerhaft im \gls{FoV} befindet, würde es bei der Bewegungsextraktion eine statische Umgebung implizieren.

Die Begrenzung des Messbereichs kann nur an einer Punktwolke erfolgen, die noch nicht in das Weltbezugssystem überführt wurde, da ein unmittelbarer Zusammenhang zwischen Messpunkte und \gls{LiDAR} benötigt wird.

#### Entfernen von Messfehlern

Nach der Begrenzung der Daten auf den gültigen Messbereich können durch stochastische Annahmen Punktwolken von Messfehlern bereinigt werden. Es ist nahezu unmöglich, Messfehler in einer Punktwolke zu identifizieren. Aus diesem Grund bedient man sich der Annahme, das Ausreißer nahe einer Ansammlung von mehreren Punkten möglicherweise Messfehler repräsentieren. Dies bezeichnet man als *statistical outlier*. Die Funktion filtert gemäß der Angabe der mittleren Punktdichte die gesamte Punktwolke und entfernt entsprechende Punkte, die sich außerhalb dieser Ansammlungen befinden. Die Gefahr bei diesem Filter besteht darin, dass auch Punkte entfernt werden können, bei denen es sich nicht um Messfehler handelt. 

#### Downsampling der Punktwolken

Scannende \gls{LiDAR}-Sensoren haben die Eigenschaft, dass die Winkelauflösung mit zunehmender Entfernung der zu messenden Hindernisse abnimmt. Das bedeutet, dass Hindernisse, die sich nah am \gls{LiDAR}-Sensor (innerhalb des Messbereiches) befinden, mit einer höheren Zahl an Hits vermessen werden. Die Struktur der Oberfläche ist somit höher aufgelöst und kleinere Unterschiede sind messbar. Befindet sich ein Hindernis jedoch weiter vom \gls{LiDAR}-Sensor entfernt, so werden die Hindernisse deutlich gröber aufgelöst als nähere.

Das heißt, dass der Nahbereich des \gls{LiDAR}-Sensors eine höhere Punktdichte aufweist. Kleine Rotationen zwischen den Punktwolken sind durch Veränderungen in der Ferne erkennbar, die Menge an Punkten im Nahbereich überwiegt jedoch, sodass diese kleinen Unterschiede für die Schätzung der Transformation nicht berücksichtigt werden.

Durch sogenanntes Downsampling werden Punkte aus der Punktwolke entfernt, um den Einfluss bestimmter Regionen auf die Registrierung zu minimieren. Im Folgenden werden zwei Varianten zum Downsampling der Punktwolken vorgestellt.

##### Voxel-Grids

Die erste Variante erzeugt ein gleichmäßiges Downsampling, das heißt, die Punktwolke wird in allen Regionen gleichmäßig ausgedünnt. Dabei werden die Punkte in einem definierten Bereich in ihrem Schwerpunkt, dem Voxel, zusammengefasst.

Das resultierende Voxel-Grid ist gleichverteilt und erfüllt die Bedingung, dass alle Regionen die gleiche Relevanz für die Bestimmung der Transformation haben. Wichtig ist, dass die Größe des Voxel-Grids auf die Verteilung der vorliegenden Daten angepasst wird, da sonst entweder zu viele oder zu wenige Punkte zusammengefasst werden.

Dieses Verfahren hat den Nachteil, dass auf Grund der Einteilung in Voxel die wahren Positionen der Punkte manipuliert werden. Die resultierende, geschätzte Transformation entspricht somit unter Umständen nicht mehr der eigentlich vorherrschenden Transformation.

##### Kovarianz-Downsampling

Nach @Gelfand2003 wirkt sich eine fehlerhafte Kalibrierung der Sensorpose negativ auf die Registrierung der Punktwolken mit dem \gls{ICP}-Algorithmus aus. Dazu analysierten sie die Daten im Vorhinein und berechnen eine geometrische Stabilität. Punktwolken sind geometrisch instabil, wenn sie keine eindeutige Transformation ermöglichen. In diesem Fall divergiert der \gls{ICP} oder fällt mit hoher Wahrscheinlichkeit in ein lokales Minimum.

Das Resultat ist eine falsche Transformation, was zum Beispiel bei planaren Flächen der Fall ist. Bei der Registrierung existieren mindestens zwei Freiheitsgrade, anhand derer die Flächen zueinander verschoben oder rotiert werden können. Dieses Problem tritt somit bei geometrischen Grundformen wie Quadern, Zylindern und Kugeln auf. Das Maß dieser geometrischen Stabilität ist die Konditionszahl der Kovarianzmatrix^[Eine Kovarianzmatrix enthält Informationen über die Streuung eines Zufallsvektors und über die Korrelationen zwischen dessen Komponenten].

\begin{figure}[htbp!]
\centering
\includegraphics[width=.7\linewidth]{Images/covariance_sampling.png}
\caption{Angewandtes Kovarianz-Downsampling (rot) und die originale Punktwolke (blau)}
\label{fig:covariance_downsampling}
\end{figure}

Die Kovarianz bezeichnet in diesem Zusammenhang die Varianz der Oberflächen-Normalen. Dazu wird die Punktwolke gemäß Abschnitt \ref{schaetzung_von_oberflaechen_normalen} analysiert. Die Kovarianzen der verschiedenen Dimensionen werden in einer Kovarianzmatrix abgelegt. Aus den Eigenvektoren der Kovarianzmatrix berechnen sie eine Konditionszahl. Im Anschluss sortieren sie die Punkte absteigend nach ihrer Unabhängigkeit von der Umgebung und entfernen die voneinander abhängigsten $70\%$ aus dem Datensatz. In ihren Experimenten konvergiert der \gls{ICP}-Algorithmus nach 25 Iterationen. Dieses Verfahren wird als Kovarianz-Downsampling bezeichnet. Abbildung \ref{fig:covariance_downsampling} zeigt einen Laserscan vor und nach dem Kovarianz-Sampling.

#### Vorgabe einer initialen Ausrichtung

Die Vorgabe einer initialen Ausrichtung bezeichnet die initiale Transformation, mit der die Eingabe-Punktwolke transformiert wird. Sie kann entweder vom Benutzer vorgegeben oder durch einen *Sample-Consensus*-Algorithmus unter Verwendung des \gls{FPFH} errechnet werden. Eine initiale Ausrichtung vermindert das Risiko, dass der \gls{ICP} zu einem lokalen Minimum konvergiert. 

Die Implementierung des *Sample-Consensus* nach @Rusu2009 ermöglicht das schnelle Sortieren nach Relevanz von einer Vielzahl an gesampelten Punkten unter der Wahrung der geometrischen Beziehungen zwischen den Punkten.

### Zusammenfassung

Die Registrierung von Punktwolken mit dem \gls{ICP}-Algorithmus ist hauptsächlich für die feiner Anpassung einer initialen Transformation gedacht und konvergiert schnell in lokale Minima, wenn diese Transformation stark vom Ziel abweicht.

Punktwolken können anhand verschiedener Filterfunktionen optimiert und angeglichen werden. Durch die Berechnung von verschiedenen Features kann zudem die Registrierung zweier Punktwolken beschleunigt und das Risiko von lokalen Minima reduziert werden.

Trotz aller Bemühungen liefert die Standard-Implementierung des \gls{ICP}-Algorithmus keine Garantie für das Auffinden eines globalen Minimums. In der Literatur existieren bereits verschiedene alternative Ansätze, die durch zusätzliche Bedingungen den \gls{ICP} eingrenzen und versuchen, entsprechende lokale Minima zu erkennen. Beispielhaft seien dafür @Yang2013, @Bellekens2014, @Belshaw2009, @Boughorbel2010, @Droeschel2011, @Gelfand2003, @Hervier2012 und @Rusinkiewicz2001 erwähnt.

Für diese Arbeit wird die Registrierung hingegen durch eine äußerlich geschachtelte Nichtlineare-Optimierung variiert. Die Punktwolken werden nicht durch den \gls{ICP} registriert, sondern seine Fehlermetrik als Variationseingabe für eine Levenberg-Marquardt Optimierung verwendet.

## Nichtlineare Optimierung nach Levenberg-Marquardt

Die Maximierung und Minimierung eines Problems ist interdisziplinär. Beispielsweise soll der Profit einer Firma maximiert, aber die Kosten und eventuelle Risiken sollen minimiert werden. Nichtlineare Optimierung betrifft Probleme, wenn die zu minimierenden Faktoren in einer nicht-linearen Funktion zueinander stehen.

Prinzipiell unterscheidet man zwischen *one-variable-* und *n-variable-optimisation*. Eine *one-variable-optimisation* kommt zum Einsatz, wenn die zu optimierende Funktion nur von einer Variablen abhängig ist. Zur Lösung gibt es zwei Methoden, wobei die erste direkt den Funktionswert (*direct-method*) verwendet und die zweite auf Ableitungen (*gradient-method*) basiert.

### One-Variable-Optimisation

Ein Optimum nach der *gradient-method* ist gegeben, wenn (@eq:optimierungs_bedingung_1) und (@eq:optimierungs_bedingung_2) zutreffen.

$$ f^\prime(x) = 0 $$ {#eq:optimierungs_bedingung_1}
$$ f^{\prime\prime}(x) \begin{cases} < 0 & \text{wenn Maximum gesucht}\\ > 0 & \text{wenn Minimum gesucht}\end{cases} $$ {#eq:optimierungs_bedingung_2}

Allgemein verwendet man die *secant-* oder die *Newton-Ralphson's method*.

#### *Secant-Method*

Die *secant-method* erfolgt entweder durch die Ableitung der Geradenfunktion oder durch die Taylor Reihe. Es handelt sich dabei um einen iterativen Prozess gemäß (@eq:secant_method), bei dem zwei Anfangsbedingungen ($x_0$ und $x_1$) ausgewählt werden und anschließend der Nachfolger $x_{i+1}$ berechnet wird. Dies wird so lange wiederholt, bis $|f^\prime(x_i) = 0|$ oder ausreichend klein ist.

$$ x_{i+1} = x_i - \frac{f^\prime(x_i)}{f(x_i) - f(x_{i+1})} \times (x_{i+1} - x_i) $$ {#eq:secant_method}

Vorteile der *secant-method* sind, dass nur die erste Ableitung $f^\prime(x_i)$ benötigt wird und die Rechnung immer zu einer Lösung des Problems führt. Nachteilig ist hingegen, dass die Funktion nicht stets zum Minimum konvergiert und keine Fehlerschranken für die berechnete Iteration bestimmt werden. Das bedeutet, dass keine Aussage gemacht werden kann, wie nah man bereits am Minimum ist.

#### *Newton-Ralphson's Method*

Eine weitere Methode zur Erfüllung der ersten Bedingung ist durch die *Newton-Ralphson's method* gegeben. Diese Methode ist ebenfalls von der Taylor-Reihe abgeleitet und wird gemäß (@eq:newton_ralphsons_method) iteriert.

$$ x_{i+1} = x_i - \frac{f^\prime(x_i)}{f^{\prime\prime}(x_i)} $$ {#eq:newton_ralphsons_method}

Die Abbruchbedingung nach der Angabe eines Startpunkts $x_0$ ist, wie bei der *secant-method*, wenn $|f^\prime(x_i) = 0|$ oder ausreichend klein ist. Dabei werden beide Ableitungen der Funktion benötigt, wobei sich die Lösungsfunktion tangential immer weiter an das Minimum annähert. Die Vorteile bestehen darin, dass sie die wenigsten Iterationen benötigt, um das Minimum zu finden und dabei quadratisch konvergiert. Die Nachteile sind, dass die Methode fehlschlägt, wenn die zweite Ableitung $|f^{\prime\prime} = 0|$ ist (Division mit $0$). Des Weiteren muss sich der initiale Punkt bereits nah am Minimum befinden.

### N-Variable-Optimisation

Wird von mehr als nur einer Variablen einer Funktion das Optimum gesucht, spricht man von *n-variable-optimistation*. Die Schreibweise dieses Problems erfolgt dabei gemäß (@eq:n_variable_denotion).

$$ f(x) = f(x_1, x_2, x_3, \ldots, x_n) $$ {#eq:n_variable_denotion}

Die erste Ableitung einer Funktion mehrerer Unbekannter $f^\prime$ wird als Matrix der partiellen Ableitungen gemäß (@eq:erste_ableitung_partiell) formuliert.

$$ f^\prime =
\begin{pmatrix}
\frac{\partial f}{\partial x_1} & \frac{\partial f}{\partial x_2} & \frac{\partial f}{\partial x_3} & \cdots & \frac{\partial f}{\partial x_n}
\end{pmatrix}^{T} $$ {#eq:erste_ableitung_partiell}

Die zweite Ableitung resultiert in der Hesse-Matrix gemäß (@eq:zweite_ableitung_hesse_matrix). Die Hesse-Matrix entspricht der Transponierten der Jacobi-Matrix des Gradienten, wobei $\frac{\partial^2f}{\partial x_i\partial x_j}$ die zweiten partiellen Ableitungen bezeichnet.

$$ f^{\prime\prime} = H_f(x) :=
\begin{pmatrix}
\frac{\partial^2f}{\partial x^2_1}(x) & \frac{\partial^2f}{\partial x_1\partial x_2}(x) & \cdots & \frac{\partial^2f}{\partial x_1\partial x_n}(x)\\
\frac{\partial^2f}{\partial x_2\partial x_1}(x) & \frac{\partial^2f}{\partial x^2_2}(x) & \cdots & \frac{\partial^2f}{\partial x_2\partial x_n}(x)\\
\vdots & \vdots & \ddots & \vdots\\
\frac{\partial^2f}{\partial x_n\partial x_1}(x) & \frac{\partial^2f}{\partial x_n\partial x_2}(x) & \cdots & \frac{\partial^2f}{\partial x^2_n}(x)\\
\end{pmatrix}
$$ {#eq:zweite_ableitung_hesse_matrix}

Damit ein Optimum gefunden werden kann, muss die erste Ableitung $|f^\prime| = 0$ sein. Die zweite Bedingung ist, dass die Eigenwerte der Hesse-Matrix positiv sein müssen.

Zur Lösung des Problems werden sogenannte *line-search*-Algorithmen verwendet.Ein *line-search*-Algorithmus ist ein iterativer Prozess, der eine Suchrichtung $p_k$ und eine Schrittweite $s$ benötigt. Jede Iteration erfolgt dabei gemäß (@eq:line_search), wobei man zwischen *weak-* und *perfect-line-search* unterscheidet. Der Unterschied besteht darin, dass im Gegensatz zur *weak-line-search* bei einer *perfect-line-search* die Schrittweite $s$ durch Berechnung angepasst wird.

$$ x_{k+1} = x_k + s * p_k $$ {#eq:line_search}

Für eine erfolgreiche *line-search* werden die drei Wolfe's Bedingungen definiert. Die erste, bekannt als *sufficient-decrease*, stellt gemäß (@eq:sufficient_decrease) sicher, dass die Schrittweite nicht zu groß gewählt wird.

$$ f(x_k + \alpha * p_k) < f(x_k) + c_1 * \alpha * \nabla^2 * f(x_k) * p_k $$ {#eq:sufficient_decrease}

Die zweite Bedingung, *curvature-condition*, stellt gemäß (@eq:curvature_condition) sicher, dass die Schrittweite ausreichend groß ist, um sich einer Lösung anzunähern.

$$ f(x_k + \alpha * p_k)^T \geq c_2 * \nabla^2 * f(x_k)^T * p_k $$ {#eq:curvature_condition}

Die letzte Bedingung wird als *strong Wolfe's condition* bezeichnet und stellt gemäß (@eq:strong_wolfes) sicher, dass sich die Suchrichtung $p_k$ in Richtung eines Minimums befindet.

$$ f(x_k + \alpha * p_k)^T \leq c_3 * \nabla^2 * f(x_k)^T * p_k $$ {#eq:strong_wolfes}

Im Folgenden werden die Suchstrategien *steepest-descent*, *Newtons-* und *quasi-Newtons-method* erläutert.

#### *Steepest-Descent*

Die erste Suchstrategie beginnt an einer Startposition $x_0$. Für jede Iteration $k=0,1,2,\ldots,n$ wird der Gradient $g_k = \nabla f$ bestimmt, die Richtung als $p_k = - \nabla f$ festgelegt sowie überprüft, dass die Richtung zum Minima gemäß (@eq:ensure_descent) gegeben ist.

$$ p_k^T * g_k < 0 $$ {#eq:ensure_descent}

Anschließend wird der nächste Punkt gemäß (@eq:next_point) bestimmt und die Schrittweite $s$ gemäß (@eq:new_step_size) aktualisiert.

$$ x_{k+1} = x_k + s * p_k^T $$ {#eq:next_point}

$$ s = d/ds $$ {#eq:new_step_size}

Dieses Verfahren wird so lange wiederholt, bis $|g_{k+1}| = 0$ ist. Die Vorteile bestehen darin, dass es die wenigsten Berechnungen erfordert, nie fehlschlägt und auf unterschiedliche Modelle skaliert werden kann. Nachteilig ist, dass die Anzahl der benötigten Iterationen nicht minimal ist.

#### *Newton's Method*

Die zweite Suchstrategie verwendet die Hesse-Matrix, um die Richtung der Suche zu bestimmen. Dazu werden nach Angabe eines Startwerts $x_0$ für alle $k = 0,1,2,,\ldots,n$ die Gradienten und die Hesse-Matrix $H_k$ berechnet. Die Richtung der Suche erfolgt gemäß (@eq:newtons_direction).

$$ p_k = H_k^{-1} * g_k $$ {#eq:newtons_direction}

Anschließend wird der neue Punkt $x_{k+1}$ sowie die Schrittweite $s$ wie beim *steepest-descent* berechnet. Die Suche endet, sobald $|g_{k+1}| = 0$ ist.

Diese Strategie konvergiert schneller als *steepest-descent*. Die Suche kommt jedoch nicht zu einer Lösung, wenn der initiale Punkt zu weit vom Minimum entfernt ist. Des Weiteren müssen die Hesse-Matrix und ihre inverse berechnet werden.

#### *Quasi-Newtons Method*

Diese Suchstrategie entspricht der *Newtons Method*, jedoch wird eine approximierte Inverse der Hesse-Matrix $H_k^{-1} = G_k$ verwendet. Nach Definition des Startpunkts $x_0$ wird der Gradient $g_k = \nabla f$ berechnet und $G_k = I$ der Identitätsmatrix gesetzt. Die Suchrichtung errechnet sich gemäß (@eq:suchrichtung_quasi_newton). Die Berechnung des nächsten Punktes $x_{k+1}$ und der Schrittweite $s$ erfolgt wieder gemäß der *Newton's Method*.

$$ p_k = -G_k * g_k $$ {#eq:suchrichtung_quasi_newton}

Im Anschluss wird die Annäherung der Hesse-Matrix angepasst. Dazu wird gemäß (@eq:gradient_difference) die Differenz der Gradienten $\gamma_k$ und gemäß (@eq:point_difference) die Differenz der Punkte $\delta_k$ berechnet.

$$ \gamma_k = g_{k+1} - g_k $$ {#eq:gradient_difference}

$$ \delta_k = x_{k+1} - x_k $$ {#eq:point_difference}

Die Annäherung der Hesse-Matrix berechnet sich gemäß (@eq:new_approximated_hessian).

$$ G_{k+1} * \gamma_k = \delta_k $$ {#eq:new_approximated_hessian}

Das Verfahren wird anschließend so oft wiederholt, bis $|g_{k+1}| = 0$ ist.

Als weitere Optimierungen existieren zwei Varianten zur Annäherung der Hesse-Matrix nach David-Fletcher-Powell (DFP) gemäß (@eq:dfp) und Broyden-Fletcher-Goldfarb-Shanno (BFGS) gemäß (@eq:bfgs).

$$ G_{k+1} = G_k - \frac{G_k \gamma_k \gamma_k^T G_k}{\gamma_k^T G_k \gamma_k} + \frac{\delta_k \delta_k^T}{\delta_k^T \gamma_k} $$ {#eq:dfp}

$$ G_{k+1} = G_k - \frac{G_k \gamma_k \delta_k^T + \delta_k \gamma_k^T G_k}{\delta_k^T \gamma_k} + \left[ 1 + \frac{\gamma_k^T G_k \gamma_k}{\delta_k^T \gamma_k} \right] \frac{\delta_k \delta_k^T}{\delta_k^T \gamma_k} $$ {#eq:bfgs}

Zusammenfassend kann gesagt werden, dass alle Suchstrategien entsprechend der Schrittweite variiert werden können. Welche Suchstrategie die beste ist, kann nicht anhand der Vor- oder Nachteile entschieden werden, sondern ist abhängig von der Funktion $f$ und dem Ausgangspunkt.

## Umsetzung der Kalibrierung im DIP-Framework

Die Kalibrierung wurde als zuschaltbarer Filter im \gls{DIP}-Framework der Abteilung \gls{ULF} implementiert. 

### Entwicklung der Softwarearchitektur

Dafür wurde die \gls{PCL} aktualisiert und die entsprechenden Programmaufrufe an die neue Version angepasst. Es wurde ein Datentyp `Ext_Pt` angelegt, der den Anforderungen für die zu verwendenden Algorithmen entspricht. Der Datentyp ermöglicht die Speicherung der Punktkoordinaten, einer Oberflächen-Normalen und einer Sensorposition. Damit die Punktwolken in den unterschiedlichen Bezugssystemen dargestellt werden können, mussten gemäß Abbildung @fig:klassendiagramm einige Änderungen an der bestehenden Codebasis vorgenommen werden.

![Klassendiagramm zur Umsetzung der Kalibrierung im DIP](Images/klasendiagramm.pdf) {#fig:klassendiagramm}

Zuerst wurde die Verzahnung zwischen Erstellung, Extraktion und Darstellung von Punktwolken aufgelöst und die Funktionalität der Darstellung in die Klasse `pointcloudVisualizer` verlegt. Jede Klasse, die Punktwolken in irgendeiner Art und Weise visualisieren möchte, kann nun von der Klasse `pointcloudVisualizer` erben und die Punktwolke in der geschützten Shared-Pointer-Variablen `cloudToDraw` speichern. Die Visualisierung erfolgt dabei in einem eigenen Thread.

Des Weiteren wurde die Umwandlung von \gls{LiDAR}-Scandaten in Punktwolken optimiert. In der bisherigen Implementierung wurden die Punktwolken redundant angelegt und mehrfach kopiert. Durch Verwendung von *shared-pointer*-Variablen konnte die Verarbeitung der Punktwolken effizienter gestaltet werden. Ebenfalls wurde die Klasse `imageToPointcloud` um die Variable `e_coordinate_system` erweitert, bei der es sich um eine Enumeration handelt. Diese Variable definiert das Bezugssystem, für das die Punktwolke aus den Scandaten berechnet werden soll. Zuvor wurden für jedes Bezugssystem eine eigene Punktwolke angelegt und bearbeitet, auch wenn von der aufrufenden Klasse nur die Punktwolke eines Bezugssystems verwendet wurde. Das Bezugssystem kann nun durch Setzen der Variablen variiert werden.

Als Nächstes wurde die Klasse `LaserNAVCalibration` erstellt. Dabei handelt es sich um den Filter, der gemäß des vorgestellten Ansatzes die einzelnen Funktionen aufruft. Die einzelnen Funktionen für Filterung, Sampling und Registrierung befinden sich außerhalb einer Klasse, ausgelagert in der Datei `pointcloudRegistration`. Die Klasse `LaserNAVCalibration` erbt zudem von der Klasse `ScannerOverview`, um die registrierten Punktwolken, den Ursprungsdatensatz sowie einzelne Zwischenprodukte während des Samplings darzustellen.

### Implementierung der optimierten Lösung

Als nicht-lineare Optimierungsfunktion wird die Implementierung nach @Gavin2011 und @Madsen1999 von @Wuttke2007 verwendet. Dabei handelt es sich um eine *n-variable-optimistation*. Die Minimierung beginnt mit der Suchstrategie *steepest-descent* und geht anschließend in die *Newton-Gauß*-Methode über. Bei der *Newton-Gauß*-Methode handelt es sich um eine weitere Optimierung der *Quasi-Newtons method*, die jedoch nur auf die Minimierung von nicht-linearen Problemen der kleinsten Quadrate angewendet werden kann. 

Die Übergabeparameter sind die zu optimierende Montagepose. Sie besteht aus drei Translationen und drei Rotationen. Die Optimierungsfunktion benötigt ein bestimmtes, im Idealfall ein überbestimmtes Gleichungssystem, sodass für sechs Unbekannte auch sechs Punktwolken-Paare benötigt werden.

Die Optimierungsfunktion berechnet für jedes Punktwolken-Paar den mittleren Punktabstand. Dazu wird eine Initiallösung vorgegeben, die zum Beispiel vom Anwender gemessen oder geschätzt wird. Mit dieser Initiallösung werden nun beide Punktwolken transformiert. Dabei werden die Punkte vom Sensor- ins Trägerbezugssystem überführt. Anschließend wird die zeitlich erste Punktwolke mit der gemessenen Bewegung, die das \gls{UA} zwischen den Aufnahmen erfahren hat, transformiert.

Bei einer korrekten Montagepose würde die erste Punktwolke nun mit der zweiten übereinstimmen. Ist dies nicht der Fall, bedeutet es, dass die Montagepose angepasst werden muss. Dafür werden die Punktwolkenabstände mit dem \gls{ICP} bestimmt und in einem Fehlervektor gespeichert. Dieses Verfahren wird für jedes Punktwolken-Paar wiederholt. Anschließend werden alle Fehler aus dem Fehlervektor aufaddiert und die Wurzel gezogen. Dieser Wert dient für die Optimierungsfunktion als Richtwert.

Nach jedem Durchlauf werden die Übergabeparameter gemäß einer mathematischen Metrik verändert und der Fehlervektor erneut berechnet. Diese Veränderung ist unter anderem abhängig von der Schrittweite $\epsilon$ und den vorherigen Fehlervektoren.

### Entwicklung der graphischen Oberfläche

Durch die Vererbung der verschiedenen Filter kann zudem nicht nur die Funktionalität des Filters, sondern auch die graphische Oberfläche des Filters übernommen und erweitert werden. Gemäß Abbildung \ref{fig:filter_oberflaeche} ist die graphische Oberfläche des `LaserNAVCalibration`-Filters in drei Teile untergliedert.

\begin{figure}[h!]
\begin{tikzpicture}
    \node[anchor=south west,inner sep=0] at (0,0) {\includegraphics[width=\textwidth]{Images/dip_filter_overview.png}};
    \draw[red,ultra thick,rounded corners] (1.2,1.9) rectangle (4.55,4.65);
    \draw[green,ultra thick,rounded corners] (4.6,1.9) rectangle (11.2,4.65);
    \draw[blue,ultra thick,rounded corners] (11.25,1.9) rectangle (13.7,4.65);
\end{tikzpicture}
\caption{Übersicht der graphischen Oberfläche des DIP-Frameworks mit hinzugeschaltetem \texttt{LaserNAVCalibration}-Filter (unterer Bildausschnitt)}
    \label{fig:filter_oberflaeche}
\end{figure}

Auf der \textcolor{red}{linken Seite} können die verschiedenen Filter- und Samplingfunktionen zur Kalibrierung zu- oder abgeschaltet werden. Dabei wurde Wert auf die gegenseitige Abhängigkeit von Filterfunktionen gelegt. Die Berechnung des Kovarianz-Samplings setzt zum Beispiel die Berechnung der Oberflächen-Normalen voraus. Deaktiviert der Benutzer die Berechnung der Oberflächen-Normalen, wird automatisch auch der Filter des Kovarianz-Samplings deaktiviert. Des Weiteren befinden sich an dieser Stelle ein `Add`- und ein `Reset`-Button, wodurch der Ablauf der Kalibrierung gesteuert werden kann.

In der \textcolor{green}{Mitte} befinden sich die von der Klasse `ScannerOverview` geerbten Steuerelemente zur Visualisierung des Ursprungsdatensatzes. Dies ermöglicht die Parametrierung der Anzahl der anzuzeigenden Punktwolken und die Einstellung der Höhenskala.

Die \textcolor{blue}{rechte Seite} ermöglicht allgemeine Einstellungen zur Visualisierung von Punktwolken, wie das darzustellende Bezugssystem und die Einfärbung der Punktwolke anhand verschiedener Eigenschaften.

### Anwendung des Filters zur relativen extrinsischen Kalibrierung

Um die Montagepose eines \gls{LiDAR}-Sensors zu einer \gls{NAV}-Sensorik zu kalibrieren, müssen die jeweiligen Scandaten und Navigations-Log-Dateien in das \gls{DIP}-Framework geladen werden. Dabei ist sicherzustellen, dass die initiale Montagepose in der Initialisierungsdatei der Scandaten wie gewünscht gesetzt ist. Anschließend werden Schlüsselszenen durch den `Add`-Button zu einem Vektor aus Punktwolkenpaaren hinzugefügt. Dabei hat das Punktwolkenpaar einen zeitlichen Abstand von 100 ms. Der `Reset`-Button setzt die bisher gewählten Schlüsselszenen komplett zurück. Hat der Benutzer mindestens sechs Schlüsselszenen hinzugefügt, beginnt die nicht-lineare Optimierung.

Im Konsolen-Ausgabefenster kann nun die Variation der Parameter beobachtet werden. Der Algorithmus endet mit einer minimierten Lösung. Nach Erhalt der neuen Montagepose wird das Punktwolkenpaar mit dem größten Fehlerwert aus dem Vektor entfernt und der Benutzer hat die Möglichkeit, eine weitere Schlüsselszene hinzuzufügen. Durch das erneute Hinzufügen wird die Optimierung mit der nun berechneten Montagepose wiederum durchlaufen.

# Validierung

Zur Validierung der Kalibrierlösung wurden zwei Experimente durchgeführt. Durch das erste Experiment *In-Flight* wird die Problematik der Kalibrierung an einem unbekanntem Aufbau analysiert. Die Ergebnisse dienten als Anhaltspunkte für den vorgestellten Kalibrierungsansatz. Mit dem zweiten Experiment *Common-Ground* wurde die Implementierung der automatisierten Kalibrierung durch die Verwendung eines konstruierten und vermessenen Aufbaus validiert. Im Folgenden werden beide Experimente bezüglich ihres Aufbaus, des Ablaufs und den jeweiligen Resultaten erläutert.

## Ausgangspunkt der Kalibrierung

Bei der Auswertung eines Filters zur Erkennung von Hindernissen anhand von Kamera und \gls{LiDAR}-Daten wurden die Aufnahmen einer Kamera mit den Entfernungsinformationen eines \glspl{LiDAR} verknüpft. Dabei trat ein Effekt gemäß Abbildung \ref{fig:hindernis_erkennung} auf, der bei bestimmten Bewegungen dazu führte, dass die Hits des \glspl{LiDAR} fehlerhaft auf das Kamerabild projiziert wurden. Dadurch wurde die Hinderniserkennung stark gestört.

\begin{figure}[hbtp!]
\centering
\includegraphics[width=.9\linewidth]{Images/fusions_fehler_schweiz}
\caption{Überlagerung von Kamera- und Laserscandaten zur Hinderniserkennung}
\label{fig:hindernis_erkennung}
\end{figure}

Für das menschliche Auge sind die fehlerhaften Detektionen an den Häuserwänden kaum zu erkennen. In der algorithmischen Analyse führen solche Messfehler zu gravierenden Rechenfehlern. Bisher ist es algorithmisch noch nicht möglich, solche perspektivischen Fehler zu erkennen und zu korrigieren. Alternativ entstand der Gedanke, dass die geschätzte und am Computer nachträglich optimierte Montagepose des \gls{LiDAR} in bestimmten Situationen zu ungenau sei. Dadurch entstand der Wunsch nach einer automatisierten extrinsischen Kalibrierung zwischen \gls{LiDAR}-Sensoren und \gls{NAV}-Sensorik.

## Verwendete Sensoren

### Der LiDAR-Sensor

Als \gls{LiDAR}-Sensor kommt der Velodyne HDL-32e (im Folgenden als Velodyne bezeichnet) zum Einsatz. Entsprechend seines Namens besitzt der Velodyne 32 vertikal angeordnete Halbleiterlaser, die in der $zx$-Ebene einen \gls{FoV} zwischen $+10^\circ$ und $-30^\circ$ ermöglichen. Gemäß Abbildung @fig:schematische_darstellung_des_velodyne_hdl_32e rotiert diese Anordnung um $360^\circ$ um seine $y$-Achse. Der Messbereich liegt bei 1 m bis 100 m mit einer Standardabweichung von +/- 2 cm bei 25 m. Die Framerate beträgt dabei 10 Hz, wobei der \gls{LiDAR}-Sensor je Scan circa 250.000 Bildpunkte als Entfernungsmessung liefert.

![Schematische Darstellung des Velodyne HDL-32e](Images/velodyne_view.png) {#fig:schematische_darstellung_des_velodyne_hdl_32e}

Der \gls{LiDAR}-Sensor misst den Rotationswinkel $\theta$, den Winkel $\phi$, die Distanz zum Objekt $d$, den Intensitätswert des jeweiligen Hits und einen intern gesetzten Zeitstempel. Die aufgenommenen Sensordaten werden per \gls{UDP} an den Rechner (Fahrzeug- beziehungsweise Flugrechner) weitergeleitet und dort von Kugelkoordinaten in kartesische Koordinaten umgerechnet.

### Die inertiale Messeinheit

Als inertiale Messeinheit wird die iMar \gls{IMU} iTraceRT-F400-Q gemäß Abbildung @fig:itrace verwendet. Die \gls{IMU} bietet eine *Deep-Coupled* Sensorumgebung aus \gls{INS} und \gls{GNSS}. Das \gls{INS} wird durch Laserkreisel und eine unbekannte Anordnung von Beschleunigungssensoren realisiert; das \gls{GNSS} unterstützt \gls{NAVSTAR-GPS}-, \gls{GLONASS}- sowie BeiDou-Satelliten.

![Produktbild der iMAR iTraceRT-F400 Q (@iMAR2013)](Images/itrace.jpg) {#fig:itrace}

Die \gls{IMU} liefert gemäß @iMAR2013 alle kinematischen Messungen wie Beschleunigung, Winkelgeschwindigkeiten, Lage, Heading, Geschwindigkeit und Position des Trägers mit einer Taktfrequenz von 400 Hz. Die Genauigkeit beträgt dabei $2$ cm in der Position, $0,01^\circ$ bezüglich der Lage, $< 1$ mg in der Beschleunigung und $0,02~\frac{m}{s}$ in der Geschwindigkeit. Die \gls{IMU} ist über eine \gls{USB} 2.0 Schnittstelle mit dem Rechner verbunden.

## Versuch - *In-Flight*

Der Versuch *In-Flight* repräsentiert den realen Einsatz der Kombination aus \gls{LiDAR} und \gls{IMU} am Forschungs-\gls{UA} des \gls{DLR}. Dabei sind die relativen Posen der Sensoren zueinander durch Mitarbeiter des \gls{DLR} geschätzt und optimiert worden. Da dieser Versuch als Urheber des Wunsches nach einer automatisierten Kalibrierung zu betrachten ist, wurden die Messdaten des Versuches soweit möglich analysiert, um das Problem besser zu verstehen.

### Aufbau

Der Träger der Sensoren war in diesem Zusammenhang das \gls{UA} Dragon 50 gemäß Abbildung @fig:versuchsaufbau_in_flight des Herstellers SwissDrones. Die Position und Lage der Sensoren zueinander wurde gemäß Tabelle @tbl:geschaetzte_pose manuell vermessen und durch optische Analyse weiter optimiert.

![SwissDrones Dragon 50 im Flugversuch](Images/versuchsaufbau_in_flight.jpg) {#fig:versuchsaufbau_in_flight}

Table: Händisch ermittelte Rotationswinkel und Abstände der Sensoren auf der Trägerplattform. {#tbl:geschaetzte_pose}

| Achse | Rotationswinkel [$^\circ$] | Abstand [mm]       |
| :---: | :---:                      | :----:             |
| $x$   | $-80,0$ +/- $10,0$         | $240,0$ +/- $30,0$ |
| $y$   | $0,0$ +/- $10,0$           | $0,0$ +/- $30,0$   |
| $z$   | $-90,0$ +/- $10,0$         | $135,0$ +/- $30,0$ |

Damit das \gls{FoV} des \gls{LiDAR} in Flugrichtung nicht eingeschränkt war, wurde der \gls{LiDAR} um $10^\circ$ geneigt am Rumpf des \gls{UA} befestigt.

### Ablauf

Das Experiment fand am 29.09.2014 von 09:30 Uhr bis 11:00 Uhr auf einem Truppenübungsplatz in St. Luzisteig im Kanton Graubünden in der Schweiz statt. Dabei wurde das \gls{UA} von Hand durch einen Sicherheitspiloten durch eine Anordnung von Häusern gesteuert und vom Bodenpersonal verfolgt. Das Experiment begann mit der Kalibrierung der inertialen Messeinheit durch das Fliegen von zwei übereinander gelegten Kreisen. Im Anschluss wurde das \gls{UA} durch großteils translatorische Bewegungen durch die Umgebung gesteuert und anschließend auf dem Startplatz wieder gelandet. Somit genügt dieser Versuch der *loop-closing* Bedingung. Abbildung \ref{fig:trajektorie_in_flight} zeigt eine 2-dimensionale Darstellung der Flugtrajektorie.

\begin{figure}[hbtp!]
\centering
\includegraphics[width=.7\linewidth]{Graphs/itraceRT_1412241971_nav_output_trajectory_2d}
\caption{Trajektorie des UA während des Versuchs \textit{In-Flight}}
\label{fig:trajektorie_in_flight}
\end{figure}

Die Montagepose des \gls{LiDAR} führt unweigerlich dazu, dass das \gls{FoV} zur Seite und nach hinten auf Grund des Fahrgestells und der Grundplatte eingeschränkt wurde. Da dies zu Fehlmessungen führte, wurden die resultierenden Daten durch einen Pass-Through-Filter bereinigt.

Im Anschluss wurden die generierten Punktwolken am Rechner betrachtet. Dabei fiel auf, dass im Datensatz gerade zu Beginn des Fluges kaum markante Hindernisse enthalten sind und die Punktwolken hauptsächlich aus ebenen Bodenaufnahmen bestehen. Beim Einflug in die Häusergegend sind sich bewegende Personen zu erkennen, sodass die Bedingung einer statischen Umgebung nicht zutrifft. Des Weiteren ist der Flug stellenweise holprig, sodass sich das Blickfeld horizontal schnell ändert.

Als Nächstes wurden die Punktwolken in verschiedenen Scan-Abständen mit dem \gls{ICP}-Algorithmus registriert und die Fehlerwerte geplottet.

### Ergebnisse

Die generierten Punktwolken dieses Versuchs sind speziell zu Beginn während der Kalibrierung der inertialen Messeinheit sehr bodenlastig, das heißt, es sind kaum Merkmale in Form von Häuserecken oder ähnlichem zu sehen. Dies wirkt sich direkt auf den \gls{ICP}-Fehler aus. Zu Beginn befindet sich das \gls{UA} in einer nicht markanten Umgebung und die Registrierung schlägt häufiger fehl. Ab der Hälfte des Fluges bewegt sich das \gls{UA} in einer Anordnung von Häusern, was sich auch gemäß Abbildung \ref{fig:icp_fitness_10} positiv auf den \gls{ICP}-Fehler auswirkt.

\begin{figure}[hbtp!]
\centering
\includegraphics[width=.7\linewidth]{Graphs/icp_fitness_10}
\caption{Abhängigkeit zwischen dem ICP-Fehler und der Scan-Umgebung}
\label{fig:icp_fitness_10}
\end{figure}

Abbildung \ref{fig:in_flight_vergleich_icp_werte} zeigt eine Vergleichsübersicht der mittleren errechneten \gls{ICP}-Fehler zwischen den Punktwolken für unterschiedliche Scan-Abstände.

\begin{figure}[hbtp!]
\centering
\includegraphics[width=.7\linewidth]{Graphs/in_flight_vergleich_icp_werte}
\caption{Gegenüberstellung der mittleren ICP-Fehler}
\label{fig:in_flight_vergleich_icp_werte}
\end{figure}

Es ist zu erkennen, dass mit steigendem Scan-Abstand auch ein höherer mittlerer \gls{ICP}-Fehler einhergeht. Der Versuch hat gezeigt, das das Resultat einer suxzessiven Registrierung von Punktwolken abhängig ist von der Struktur des Scans, den Abständen der zur Registrierung verwendeten Scans und der Position des \glspl{LiDAR} am Träger.

## Versuch - *Common Ground*

Der Versuch *Common Ground* dient der Bestimmung der Genauigkeit und der Anwendbarkeit der Kalibrierungslösung.

### Aufbau

Der Aufbau besteht aus den zur Kalibrierung benötigten Geräten gemäß Tabelle {@tbl:Common-Ground-Geraete}, die auf einer gemeinsamen Trägerplattform gemäß Abbildung @fig:traegerplattform befestigt sind.

Table: Geräteübersicht. {#tbl:Common-Ground-Geraete}

| Anzahl | Gerät                      | Modell               |
| :---   | :--                        | :---                 |
| 1      | \gls{LiDAR}                | Velodyne HDL-32e     |
| 1      | \gls{IMU}                  | iMAR iTrace RT-F400Q |
| 2      | \gls{NAVSTAR-GPS}-Antennen | Novatel              |
| 1      | Spannungsversorgung        | \gls{DLR}-Eigenbau   |
| 1      | Flugcomputer               | \gls{DLR}-Eigenbau   |

![Trägerplattform im Versuch *Common-Ground*](Images/versuchsaufbau_common_ground.jpg) {#fig:traegerplattform}

Der Aufbau wurde bezüglich der Winkel und Abstände gemäß {@tbl:winkel_und_abstaende_im_aufbau} kalibriert.

Table: Rotationswinkel und Abstände der Sensoren auf der Trägerplattform. {#tbl:winkel_und_abstaende_im_aufbau}

| Achse | Rotationswinkel [$^\circ$] | Abstand [mm]       |
| :---: | :---:                      | :----:             |
| $x$   | $90,0$ +/- $5,0$           | $325,0$ +/- $10,0$ |
| $y$   | $0,0$ +/- $5,0$            | $0,0$ +/- $10,0$   |
| $z$   | $90,0$ +/- $5,0$           | $20,0$ +/- $10,0$  |

### Ablauf

Zu Beginn wurde der Aufbau im Forschungstransporter des \gls{DLR} verbaut. Dabei wurde Wert darauf gelegt, dem \gls{LiDAR} ein offenes Blickfeld durch die geöffneten Ladeklappen zu ermöglichen. Der \gls{LiDAR} benötigt keine weitere Inbetriebnahme, er liefert Umgebungsscans per Ethernet-Schnittstelle, sobald er mit einer Spannung versorgt wird.

Die \gls{IMU} benötigt zur Bestimmung der Position mindestens eine \gls{NAVSTAR-GPS}-Antenne, deren relative Montageposition gemäß Tabelle @tbl:montageabstaende_zwischen_der_gps_antenne_und_der_imu vermessen wurde.

Table: Montageabstände zwischen der GPS-Antenne und der IMU. {#tbl:montageabstaende_zwischen_der_gps_antenne_und_der_imu}

| Achse | Abstand [m]        |
| :-:   | :----:             |
| $x$   | $-3,03$ +/- $0,10$ |
| $y$   | $0,71$ +/- $0,10$  |
| $z$   | $1,175$ +/- $0,10$ |

Die Anleitung des Herstellers zur Inbetriebnahme der \gls{IMU} war nicht eindeutig genug, sodass der Ablauf im Feldversuch ermittelt werden musste. Die verwendete \gls{IMU} wird hauptsächlich für den Automobilbetrieb eingesetzt. Da für den Automobilbetrieb andere Koordinatensystem-Konventionen als im Bereich der Luft- und Raumfahrt verwendet werden, muss die \gls{IMU} entsprechend konfiguriert werden. Dazu wurde die Ausrichtung der \gls{IMU} und dem Träger (in diesem Fall das Forschungsfahrzeug) gemäß Tabelle @tbl:winkeldifferenz_der_imu bestimmt.

Table: Ausrichtung der IMU im Fahrzeugbezugssystem. {#tbl:winkeldifferenz_der_imu}

| Winkel   | Betrag [$^\circ$] |
| :-:      | :---:             |
| $\Phi$   | $0,0$ +/- $5,0$   |
| $\Theta$ | $0,0$ +/- $5,0$   |
| $\Psi$   | $90,0$ +/- $5,0$  |

Das Experiment wurde am 25. Juni 2015 von 15:00 Uhr bis 16:00 Uhr in der Wohngegend Hondelage bei Braunschweig durchgeführt. Die Lokalität und die Uhrzeit wurden gewählt, um während des Experiments eine großteils statische Umgebung zu ermöglichen, sodass die Laserscans nicht durch andere Verkehrsteilnehmer verfälscht werden konnten. Andererseits hätte die so erhaltene Dynamik die Berechnung der Montagepose erschwert. Das Experiment wurde dreimal durchgeführt.

Bei dem Versuch wurden insgesamt $2395$ Laserscans in $95,8$ Sekunden aufgenommen. Die Auflösung eines Laserscans betrug dabei $2000 \times 32$ Bildpunkte, die in die Punktwolken übertragen wurden.

\begin{figure}[hbtp!]
\centering
\includegraphics[width=.8\linewidth]{Images/top_down_view_with_height_map}
\caption{Draufsicht des Versuchs \textit{Common Ground} im Höhenprofil}
\label{fig:top_down_view_with_height_map}
\end{figure}

Abbildung \ref{fig:top_down_view_with_height_map} zeigt die aufgenommenen Punktwolken nach der Transformation ins Weltbezugssystem in einer Draufsicht. Die Farbe repräsentiert die relative Höhe der Punkte, wobei die Farben von Rot (nah am Boden) in Grün (circa $10$ m über dem Boden) übergehen. Die Strecke des Experiments genügt der *Loop Closing*-Bedingung, sodass eine gleichmäßige Anzahl an Rotationen für die Auswahl der Schlüsselszenen zur Verfügung stehen (drei rechts- und vier Linkskurven). Für die translatorischen Schlüsselszenen stehen acht verschiedene Abschnitte zur Verfügung.

Nach dem Experiment wurden die Schlüsselszenen ausgewählt. Dafür wurden die Bewegungsdaten mit unterschiedlichen Scanabständen^[Ein Scanabstand bezeichnet die Anzahl an Scans, die zwischen zwei Scanpaaren ignoriert werden.] ($1$, $2$, $10$ und $100$) geplottet. Die Auswertung zeigt, dass bei einem Abstand von 100 die Differenz zwischen den Laserscans zu groß war, um noch ausreichende Merkmale zur Registrierung zur Verfügung zu stellen. Bei den Abständen von 1 und 2 Laserscans war hingegen die Geschwindigkeit des Versuchsträgers zu gering, sodass die gemessenen Translationen und Rotationen zu nah aneinander lagen. Aus diesem Grund werden für die weitere Auswertung Abstände von 10 Scans zwischen den Schlüsselszenen verwendet.

\begin{figure}[hbtp!]
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/movement_10_between_rotations_length}
      \caption{Rotationen}
      \label{fig:rotations_schluesselszenen}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/movement_10_between_translations_length}
      \caption{Translationen}
      \label{fig:translations_schluesselszenen}
    \end{subfigure}
    \caption{Analyse der Punktwolken-Paare auf markante Bewegungen}
    \label{fig:auswahl_der_schluesselszenen}
\end{figure}

Zur Auswahl der rotatorischen Schlüsselszenen wurden gemäß Abbildung \ref{fig:rotations_schluesselszenen} die Summe der quadratischen Wurzeln aus den einzelnen Winkeln $\Phi_d$, $\Theta_d$ und $\Psi_d$ gebildet. Anschließend wurden die Maxima bestimmt, absteigend sortiert und die oberen drei abgespeichert. Für die Translationen wurde gemäß Abbildung \ref{fig:translations_schluesselszenen} auf Basis der Wurzel der quadratischen Summen aus den einzelnen Koordinatenanteilen $x_d$, $y_d$ und $z_d$ ebenso verfahren. Aus dieser Analyse wurden die Punktwolken-Paare $42$, $79$ und $200$ für die Rotationen und $137$, $167$ und $190$ für die Translationen als Schlüsselszenen ausgewählt.

Der Ansatz wurde dabei unter Vorgabe der gemessenen, gemäß Tabelle @tbl:winkel_und_abstaende_im_aufbau, und der falschen (alle Winkel und Translationen wurden auf 0 gesetzt) Lösung validiert. Dabei wurden die Kalibrierungen einmal im Welt- und im Sensorbezugssystem durchgeführt sowie die Punktwolken jeweils (a) ohne Filterung betrachtet, beziehungsweise (b) durch das Voxel-Grid, (c) durch das Kovarianz-Downsampling und (d) Voxel-Grid + Kovarianz-Downsampling reduziert. Die Parameter für die Filter- und Samplingfunktionen entsprachen denen von @Stellmacher2014 ermittelten Standardwerten.

### Ergebnisse

Abbildung \ref{fig:gegenueberstellung_der_geschaetzten_montageposen} zeigt die Gegenüberstellung der 16 durchgeführten Messungen. Es ist zu erkennen, dass unter der Vorgabe der korrekten Montagepose die Kalibrierung der Pose im Sensor- wie auch im Weltbezugssystem zur korrekten Lösung konvergiert. Im Sensorbezugssystem ist die Lösung der Position in Bezug auf die $x$- und $z$-Achse falsch. Des Weiteren ist zu erkennen, dass die Kalibrierung im Sensorbezugssystem unter der korrekten Vorgabe der Lösung im Durchschnitt höhere \gls{ICP}-Fehler vorweist als im Weltbezugssystem.

\begin{figure}[hbtp!]
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/sensor_korrekte_pose_loesungsbereiche}
      \caption{Sensorbezugssystem (korrekte Vorgabe)}
      \label{fig:sensor_korrekte_pose_loesungsbereiche}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/sensor_falsche_pose_loesungsbereiche}
      \caption{Sensorbezugssystem (falsche Vorgabe)}
      \label{fig:sensor_falsche_pose_loesungsbereiche}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/welt_korrekte_pose_loesungsbereiche}
      \caption{Weltbezugssystem (korrekte Vorgabe)}
      \label{fig:welt_korrekte_pose_loesungsbereiche}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/welt_falsche_pose_loesungsbereiche}
      \caption{Weltbezugssystem (falsche Vorgabe)}
      \label{fig:welt_falsche_pose_loesungsbereiche}
    \end{subfigure}
    \caption{Gegenüberstellung der berechneten Montageposen im Sensor- und Weltbezugssystem unter der Vorgabe einer falschen und der korrekten Montagepose}
    \label{fig:gegenueberstellung_der_geschaetzten_montageposen}
\end{figure}

Bei der falschen Vorgabe ist zu erkennen, dass die Lösung der Lage im Sensor- wie auch im Weltbezugssystem in die korrekte Richtung geht, jedoch um mehrere Größenordnungen zu groß ist. Auf den ersten Blick erscheint dies als eine falsche Lösung. Bei genauerer Betrachtung der Messdaten fällt hingegen auf, dass es sich dabei um positive oder negative Vielfache der korrekten Lösung handelt. Bezüglich der Translation bietet die Kalibrierung im Sensorbezugssystem die besten Ergebnisse.

Bezüglich der Filterfunktionen kann keine eindeutige Aussage getroffen werden, welche besser geeignet ist. Es ist zu beobachten, dass außer im Weltbezugssystem mit falscher Vorgabe die Kalibrierung ohne Filterung rotatorisch sehr gute Ergebnisse liefert. Auffällig ist, dass die gleichzeitige Anwendung des Kovarianz-Downsampling und des Voxel-Grids im Sensorbezugssystem starke Fehler im Bezug auf $\Theta$ aufweist. Unter der falschen Vorgabe ist dieser Winkel eine komplette Drehung, sodass er zumindest korrigierbar ist. Die Position kann mit keiner der vorgestellten Methoden eindeutig bestimmt werden.

\begin{figure}[hbtp!]
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/sensor_korrekte_pose_score_szene_6}
      \caption{Sensorbezugssystem (korrekte Vorgabe)}
      \label{fig:sensor_korrekte_pose_score_szene_6}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/sensor_falsche_pose_score_szene_6}
      \caption{Sensorbezugssystem (falsche Vorgabe)}
      \label{fig:sensor_falsche_pose_score_szene_6}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/welt_korrekte_pose_score_szene_6}
      \caption{Weltbezugssystem (korrekte Vorgabe)}
      \label{fig:welt_korrekte_pose_score_szene_6}
    \end{subfigure}
    \begin{subfigure}{.5\textwidth}
      \centering
      \includegraphics{Graphs/welt_falsche_pose_score_szene_6}
      \caption{Weltbezugssystem (falsche Vorgabe)}
      \label{fig:welt_falsche_pose_score_szene_6}
    \end{subfigure}
    \caption{Gegenüberstellung der Konvergenz über die Anzahl der benötigten Iterationen und des fortlaufenden ICP-Fehlers}
    \label{fig:gegenueberstellung_der_konvergenz_gegen_iteration}
\end{figure}

Die Abbildung \ref{fig:gegenueberstellung_der_konvergenz_gegen_iteration} zeigt die Gegenüberstellung der Konvergenz der verschiedenen Filterungen gegenüber der benötigten Anzahl an Iterationen. Es ist zu erkennen, dass im Falle der korrekten Vorgabe alle Filterungen schneller konvergieren als unter der falschen Vorgabe. Des Weiteren fällt auf, dass unter der falschen Vorgabe größere Optimierungsschritte ausgeführt werden. Daraus resultiert ein deutlich schwankender \gls{ICP}-Fehler, der jedoch erwartungsgemäß mit fortschreitenden Iterationen abflacht. Bis auf die Außnahme des Weltbezugssystems unter der falschen Vorgabe benötigt die Methode ohne Filterung deutlich mehr Iterationen bis zur Konvergenz. Am schnellsten konvergiert die Kalibrierung unter Einsatz der kombinierten Filterung.

## Ergebnisanalyse

Es kann festgehalten werden, dass die Kalibrierung unter Vorgabe einer fast korrekten Montagepose im Weltbezugssystem die besten Ergebnisse erzielt hat. Ebenfalls sind die Rotationen in Form von Vielfachen eindeutiger zu bestimmen. Bezüglich der Translationen wiesen die Messergebnisse einige Schwierigkeiten auf.

Welche Filterfunktion die besten Ergebnisse liefert, ist nicht erkennbar. Des Weiteren wurden die Filterfunktionen mit ihren Standardparametern verwendet, die bezüglich der vorliegenden \gls{LiDAR}-Scans optimiert werden können. Die zuverlässigsten Ergebnisse liefert die Kalibrierung ohne jegliche Filterung, zumindest, wenn eine korrekte Vorgabe zur Montagepose gegeben ist.

Des Weiteren gilt es zu beachten, dass auch die Trägerplattform sowie die Sensoren im Allgemeinen Fehler aufweisen. Besonders beim Versuch *In-Flight* sind zudem Auswirkungen durch den Flugpfad und der Umgebung nicht auszuschließen. Ebenfalls wirkt sich die Auswahl der Schlüsselszenen auf die Kalibrierung aus, da zu kleine oder zu große Bewegungsänderungen zu Schwierigkeiten in der Registrierung führen.

Alle aufgenommenen und ausgewerteten Daten können in einem iPython Notebook, das sich auf dem beigelegten Datenträger und unter dem GitHub-Repository \url{https://github.com/gismo141/mastersthesis} befindet, nachverfolgt und weiterführend ausgewertet werden.

# Fazit und Ausblick

In dieser Arbeit wurde ein Ansatz zur automatisierten relativen extrinsischen Kalibrierung von bildgebenden Sensoren zu einer \gls{NAV}-Sensorik vorgestellt. Ziel war es, durch den Vergleich von paarweise registrierten Punktwolken und den parallel aufgezeichneten Bewegungsdaten eine Montagepose zu bestimmen.

Da der \gls{ICP}-Algorithmus ohne initiale Ausrichtung in ein lokales Minimum fällt, wurde die Registrierung der Punktwolken in einem nicht-linearen Optimierungsalgorithmus nach Levenberg-Marquardt geschachtelt.

Diese Optimierungsfunktion benötigt für jede Unbekannte einen Startwert, der über einen Liniensuchalgorithmus, zu Beginn *steepest-descent* und anschließend *Newton-Gauß*, optimiert wird. Dazu werden Datensätze durch den Benutzer ausgewählt, die eine markante Bewegung des Trägers in Form von Rotationen und Translationen aufweisen.

Grundlage für die Optimierung ist dabei eine Fehlermetrik. Diese Fehlermetrik entspricht der mittleren euklidischen Distanz zwischen der Punktwolke vor der Bewegung und der Punktwolke nach der Bewegung.

Da die vorliegenden Datensätze die Eigenschaft einer ungleichmäßig verteilten Punktwolke aufweisen, wurden einige Funktionen zur Filterung und für das Downsampling implementiert. Alle vorgestellten Funktionen wurden entsprechend ihrer Standardparameter verwendet.

Die Ergebnisse zeigen, dass trotz Verwendung der Funktionen zur Optimierung der Punktwolken sowie der geschachtelten Optimierung der Montagepose kein globales Minimum garantiert werden kann. Für die weitere Betrachtung der Thematik sollte besonderes Augenmerk auf die Parametrisierung der Filter- und Samplingfunktionen gelegt werden. Am vielversprechendsten ist dabei das *Covariance-Sampling*, da es die Möglichkeit bietet, planare Flächen zu entfernen und die Punktwolke auf markante Stellen zu reduzieren. Dadurch werden geometrisch stabilere Punktwolken geschaffen und lokale Minima vermieden.

Des Weiteren wurde beobachtet, dass die gleichzeitige Optimierung von Translation und Rotation nicht ideal ist, da die Rotationen einen größeren Einfluss auf das Resultat der Optimierung hatten als die Translationen. Es wird empfohlen, für zukünftige Anwendungen die Optimierung der Translation und Rotation getrennt zu betrachten oder die Parameter unterschiedlich zu gewichten.

Bildgebende Sensoren bieten die Möglichkeit, die Umgebung nicht nur zu vermessen, sondern sie auch zu kategorisieren. Da die Automatisierung von Abläufen immer weiter voranschreitet, wird die Extraktion von Bewegungen meiner Meinung nach in Zukunft einen sehr hohen Stellenwert einnehmen.

Bereits heute werden Fahrzeugführer durch unterschiedliche Assistenzsysteme unterstützt. Im Kraftfahrzeugbereich zählen zum Beispiel Geschwindigkeitsregelung, Spur- und Abstandsassistenten sowie Navigationssysteme bereits zum Repertoire der Werksausstattung. In der Luftfahrt halten seit einigen Jahren Autopiloten sowie Systeme zur automatisierten Landung Einzug. Im Bereich der Schifffahrt werden Containerschiffe bereits vollautomatisiert durch eine minimale Besatzung gefahren.

Auch der Gütertransport befindet sich im Wandel zur Automatisierung. So forschen Versandunternehmen wie Amazon bereits an selbstfliegenden \gls{UA} zur individuellen Paketzustellung; auch in der Überwachung durch Polizeibehörden werden vermehrt automatisierte Systeme eingesetzt.

Die vorliegende Arbeit legt mit der automatisierten Kalibrierung einen Grundstein für zukünftige Entwicklungen.

\chapter*{Literaturverzeichnis}
\addcontentsline{toc}{chapter}{Literaturverzeichnis}