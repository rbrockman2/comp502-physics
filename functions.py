from math import sqrt, acos

# splits event into individual entries to be parsed
def splitline(line):
  return [x for x in line.split(' ') if x != '']

# Adds sublists up pointwise to return a "net" list.
# Used most often for getting net energy-momentum 4-vector
def sumzip(list):
  return map(sum, zip(*list))

# Get only the energy-momentum components from an event group 
def get_pe(event):
  return map(float, splitline(event)[3:7])

# Calculate invariant mass given an energy-momentum 4-vector
def invariant_mass(pe):
  return sqrt(pe[3]**2 - (pe[0]**2 + pe[1]**2 + pe[2]**2))

# For now, calculate RMS error from mass of top quark and W boson
def top_W_error(M3, M2):
  m_top = 172.9; m_W = 80.385
  return sqrt((M3 - m_top)**2 + (M2 - m_W)**2)

# Write the elements of an array to a file, one element per line
def write_array_to_file(filename, ary):
  f = open(filename, 'w')
  for m in ary:
    f.write(str(m))
    f.write('\n')
  f.close()

# calculates the dot product of two vectors
def dot(x,y):
  if len(x) != len(y):
    return 
  return sum(x_i*y_i for x_i,y_i in zip(x,y))

# calculates 2-norm of a vector
def norm(x):
  return sqrt(sum(x_i**2 for x_i in x))

def angle(x,y):
  return abs(acos( dot(x,y) / (norm(x) * norm(y)) ))


def get_jets_from_file(filename):
  all_files = []; curr_file = []
  read_flag = False
  N = 0

  # ------------------------------
  # READ FILE AND PARSE RECOS ONLY
  # ------------------------------
  for line in open(filename):
    if line.strip() == 'EndReco':
      read_flag = False
      all_files.append(curr_file)
      curr_file = []
      N += 1
    if read_flag:
      curr_file.append(line)
    if line.strip() == 'BeginReco':
      read_flag = True

  events_by_file = []

  for n in range(len(all_files)):
    # -----------------------------------
    # READ RECOS AND GET 1 EVENT PER LINE
    # -----------------------------------
    lines = [l[1:-1] for l in all_files[n]]
    if lines == []: continue

    events = []; curr_event = []
    for line in lines:
      # ignore BeginReco/EndReco or line w/ number of events
      if len(line) <= 10: continue
      curr_event.append(line)
      if line[-1] in ['T', 'F']: # marks the end of an event
        events.append(''.join(curr_event))
        curr_event = []

    # -----------------------------------
    # GET JETS AND BOTTOM QUARK EVENTS
    # -----------------------------------
    bottoms = []; jets = []
    for event in events:
      entries = splitline(event)
      if len(entries) >= 13 and entries[2] == '4': # jet
        # separate bottom quarks from non-tagged jets
        bottoms.append(event) if entries[13] == '5.' else jets.append(event)

    events_by_file.append((events, bottoms, jets))

  return events_by_file