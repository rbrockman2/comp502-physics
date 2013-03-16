# ------------------------------------------
# Onkur Sen
# 
# get_energy_dist.py
#
# Usage: python get_energy_dist.py [filename]
# 
# Reads all events from a single source file
# (SUSY or ttj) and plots the distribution
# of energies of all untagged jets.
# ------------------------------------------

from functions import *
from sys import argv
from ROOT import TH1F, TCanvas
from time import time
import os

print 'Reading events from source file %s' % argv[1]
t = time()
events_by_file = get_jets_from_file(argv[1])
print 'Done. Took %f secs.' % (time()-t)

print
print 'Getting energies from %d events' % len(events_by_file)
t = time()
energies = []
for (events, bottoms, jets) in events_by_file:
  energies.extend(float(splitline(j)[6]) for j in jets)
print 'Done. Took %f secs.' % (time()-t)

print
print 'Number of energies read:', len(energies)
print 'Highest energy:', max(energies)

print
print 'Filling histogram.'
t = time()
histo = TH1F('energies', 'Energy Distribution', 50, 0, 1000)
for e in energies: histo.Fill(e)
print 'Done. Took %f secs.' % (time()-t)

print
print 'Drawing histogram. Press any key to close.'
c1 = TCanvas('c1','c1',800,800)
histo.Draw()
raw_input()

print 'Saving histogram.'
if not os.path.isdir('plots'): os.system('mkdir plots')
c1.SaveAs('plots/energies_%s.png' % argv[1])
