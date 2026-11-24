set terminal pngcairo size 800,600 enhanced font 'Arial, 12'
set output 'queue_vergleich.png'

set title "Verlgeich zwischen Löschen und Erstellen"
set xlabel "Operation"
set ylabel "Zeit in ms"

set datafile separator ":"
set style data histograms
set style fill solid
set boxwidth 0.6
set xtic rotate by -90

plot 'graph.dat' using 2:xtic(1) linecolor "blue" notitle
