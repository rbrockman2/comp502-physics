# ------------------------------------------
# Onkur Sen
# 
# get_bdt_variables.py
#
# Usage: python get_bdt_variables.py [filename]
# 
# Reads all event runs from a file,
# separates each run into two bjj systems,
# and keeps track of important variables
# to feed into a boosted decision tree (BDT).
# ------------------------------------------

from functions import *
from itertools import combinations
from math import sqrt
from sys import argv
from time import time
import os

def get_best_bjj(bottoms, jets):
  """
  Selects two bjj combinations with highest vectorially summed transverse momentum. Returns the combination with a smaller least-squares error from the top quark and W boson.
  """
  if len(jets) < 2: return None, None, None 
  # ------------------------------------------
  # SELECT TWO bjj GROUPS WITH HIGHEST P_T
  # ------------------------------------------
  
  first = [0, '', '', '']; second = [0, '', '', ''] # keep track of bjj groups with top two p_t
  jet_combos = set(combinations(jets, 2)) # all pairs of jets

  for b in bottoms:
    bsplit = [x for x in b.split(' ') if x != '']
    for (j1, j2) in jet_combos:

      # p_x and p_y for both events
      p1, p2 = map(float, splitline(j1)[3:5]), map(float, splitline(j2)[3:5])

      p = map(sum, zip(p1, p2))           # net x,y-momentum
      p_t = sqrt(p[0]**2 + p[1]**2)  # transverse momentum p_t

      # keep groups with two highest p_t
      if p_t > first[0]:
        second = first
        first = [p_t, b, j1, j2]
      elif p_t > second[0]:
        second = [p_t, b, j1, j2]

  # limiting case: if only 2 jets, then second will never be assigned
  if second[0] == 0: second = first

  # ----------------------------
  # CALCULATE M3 FOR BOTH GROUPS
  # ----------------------------
  pe1, pe2 = map(get_pe, first[1:]), map(get_pe, second[1:]) # individual energy-momentum 4-vectors
  print pe1
  print pe2
  #pause
  pe_net1, pe_net2 = sumzip(pe1), sumzip(pe2) # net energy-momentum of both groups

  if pe_net1 == []: return
  M3_1, M3_2 = invariant_mass(pe_net1), invariant_mass(pe_net2) # invariant mass

  # ------------------------------------
  # CALCULATE M2 FOR JETS IN BOTH GROUPS
  # ------------------------------------
  pe_jets1, pe_jets2 = sumzip(pe1[1:]), sumzip(pe2[1:]) # net energy-momentum for jets
  M2_1, M2_2 = invariant_mass(pe_jets1), invariant_mass(pe_jets2) # invariant mass

  # -------------------------------------------------------
  # CALCULATE ERROR FROM b, W MASSES AND ASSIGN BEST TOP QUARK
  # COLLECT M3 AND M2 CORRESPONDING TO TOP QUARK A ACROSS MULTIPLE EVENTS
  # -------------------------------------------------------
  err1, err2 = top_W_error(M3_1, M2_1), top_W_error(M3_2, M2_2)
  if err1 <= err2:
    return first, M3_1, M2_1
  else:
    return second, M3_2, M2_2

def main():
  M3A = []; M2A = []; M3B = []; M2B = []
  B_ANGLES = []; J1_ANGLES = []; J2_ANGLES = []; MISSING_E = []
  enough_bottoms = 0; has_topA = 0; has_topB = 0

  print 'Reading events from source file %s' % argv[1]
  t = time()
  events_by_file = get_jets_from_file(argv[1])
  print 'Done. Took %f secs.' % (time()-t)
  print
  print 'Iterating through %d events.' % len(events_by_file)
  t = time()

  for i in range(len(events_by_file)):
    (events, bottoms, jets) = events_by_file[i]
    #print events
    #%print bottoms
    #print jets

    #pause

    if len(bottoms) < 2:
      # print 'Event %d has too few bottom quarks' % i
      continue
    else: enough_bottoms += 1

    # -----------------------------------
    # BEST BJJ COMBO = TOP QUARK A
    # BEST BJJ COMBO FROM REMAINING JETS = TOP QUARK B
    # -----------------------------------
    topA, m31, m21 = get_best_bjj(bottoms, jets);
    if not topA:
      continue
    else: has_topA += 1

    # Remove bjj of A from the set of bottoms and jets to consider for system B
    bottoms2 = [x for x in bottoms if x != topA[1]]
    jets2 = [x for x in jets if x not in topA[2:]]
    topB, m32, m22 = get_best_bjj(bottoms2, jets2)
    if not topB:
      continue
    else: has_topB += 1

    # -----------------------------------
    # AZIMUTHAL ANGLE CUTS
    # -----------------------------------

    # Sum transverse momentum components of ALL events in collision
    # Theoretically should be 0, but it won't be 
    pT_file_total = sumzip([get_pe(event) for event in events])[:2]

    # "missing" transverse momentum = negative of sum
    pT_missing = [-1*x for x in pT_file_total]

    # transverse momentum vector of each in bjj of system B
    pT_bjjB = [get_pe(topB[k])[:2] for k in range(1, 4)]

    # azimuthal angle in between each jet and missing transverse momentum
    angles = [angle(j, pT_missing) for j in pT_bjjB]

    M3A.append(m31)
    M2A.append(m21)
    M3B.append(m32)
    M2B.append(m22)
    B_ANGLES.append(angles[0])
    J1_ANGLES.append(angles[1])
    J2_ANGLES.append(angles[2])
    MISSING_E.append(norm(pT_missing))

  print 'Done. Took %f secs.' % (time()-t)
  print
  print 'Total number of events: %d' % len(events_by_file)
  print 'Number of events with enough bottom quarks: %d' % enough_bottoms
  print 'Number of events with top quark system A: %d' % has_topA
  print 'Number of events with top quark system B: %d' % has_topB

  # ------------------------------------------------------
  # OUTPUT VALUES TO FILES FOR ROOT PLOTTING
  # ------------------------------------------------------
  print
  print 'Outputing variables for BDT processing:'
  variables = ['m3a', 'm2a', 'm3b', 'm2b', 'angles_b', 'angles_j1', 'angles_j2', 'missing_pT']
  for (i, var) in zip(range(len(variables)), variables):
    print '%d. %s' % (i+1, var)

  #if not os.path.isdir('bdt_variables_new'): os.system('mkdir bdt_variables_new')

  dlm = ',';

  if not os.path.isdir('OutputDerVars'):
    os.system('mkdir OutputDerVars')


  filepath = 'OutputDerVars/DV' + argv[1] + '.txt';

  f = open(filepath, 'w')
  for i in range(0,len(M3A)):
    f.write(str(M3A[i]))
    f.write(dlm)
    f.write(str(M3B[i]))
    f.write(dlm)
    f.write(str(M2A[i]))
    f.write(dlm)
    f.write(str(M2B[i]))
    f.write(dlm)
    f.write(str(B_ANGLES[i]))
    f.write(dlm)
    f.write(str(J1_ANGLES[i]))
    f.write(dlm)
    f.write(str(J2_ANGLES[i]))
    f.write(dlm)
    f.write(str(MISSING_E[i]))
    f.write(dlm)
    f.write('signal')
    f.write(dlm)
    f.write('\n')
  f.close()

  # write_array_to_file('bdt_variables/m3a.txt', M3A)                 # 1. M3 OF TOP QUARK A
  # write_array_to_file('bdt_variables/m3b.txt', M3B)                 # 2. M2 OF TOP QUARK A
  # write_array_to_file('bdt_variables/m2a.txt', M2A)                 # 3. M3 OF TOP QUARK B
  # write_array_to_file('bdt_variables/m2b.txt', M2B)                 # 4. M2 OF TOP QUARK B
  # write_array_to_file('bdt_variables/angles_b.txt', B_ANGLES)       # 5. AZIMUTHAL ANGLES FOR BOTTOM QUARK B
  # write_array_to_file('bdt_variables/angles_j1.txt', J1_ANGLES)     # 6. AZIMUTHAL ANGLES FOR JET 1 IN SYSTEM B
  # write_array_to_file('bdt_variables/angles_j2.txt', J2_ANGLES)     # 7. AZIMUTHAL ANGLES FOR JET 2 IN SYSTEM B
  # write_array_to_file('bdt_variables/missing_pT.txt', MISSING_E)    # 8. MISSING TRANVERSE ENERGY E_T

if __name__ == "__main__":
  main()