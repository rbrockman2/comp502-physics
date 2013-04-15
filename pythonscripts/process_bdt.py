# ------------------------------------------
# Onkur Sen
# 
# process_bdt.py
#
# Usage: python process_bdt.py
# 
# Reads files with information on parameters
# that is processed from get_bdt_variables.py
# and feeds input into a boosted decision
# tree (BDT). Signal-background separation is
# plotted, and classification of events in
# another input file is attempted.
# ------------------------------------------

import ROOT
from time import strftime, localtime
import array

# ------------------------------------
# PREPARE DATA TO BE FED INTO BDT
# ------------------------------------

def to_float_array(filename):
  return map(float, open(filename).read().split('\n')[:-1])

# variables used for consideration in BDT
variables = [
  'm3a',
  'm2a',
  'm3b',
  'm2b',
  'angles_b',
  'angles_j1',
  'angles_j2',
  'missing_pT'
]

susy = []; ttj = [];
for v in variables:
  susy.append(to_float_array('bdt_variables/train-susy/%s.txt' % v))
  ttj.append(to_float_array('bdt_variables/train-ttj/%s.txt' % v))

# fill ROOT nTuple with signal and background variables
ntuple = ROOT.TNtuple("ntuple","ntuple","%s:signal" % ':'.join(variables))
for i in range(min([len(var) for var in susy])):
  curr = [var[i] for var in susy] + [1] # susy is signal
  ntuple.Fill(*curr)

for i in range(min([len(var) for var in ttj])):
  curr = [var[i] for var in ttj] + [0] # ttbar is background
  ntuple.Fill(*curr)

print 'NTuple prepared to be fed into BDT'

# -------------------------------------------------------------------
# CREATE AND TRAIN BDT USING ROOT TMVA
# Code taken from: 
# http://aholzner.wordpress.com/2011/08/27/a-tmva-example-in-pyroot/
# -------------------------------------------------------------------

fout = ROOT.TFile("test.root","RECREATE")

factory = ROOT.TMVA.Factory(
  "TMVAClassification", fout,
  ":".join([
    "!V",
    "!Silent",
    "Color",
    "DrawProgressBar",
    "Transformations=I;D;P;G,D",
    "AnalysisType=Classification"]
  ))

for v in variables:
  factory.AddVariable(v,"F")

factory.AddSignalTree(ntuple)
factory.AddBackgroundTree(ntuple)

# cuts defining the signal and background sample
sigCut = ROOT.TCut("signal > 0.5")
bgCut = ROOT.TCut("signal <= 0.5")

factory.PrepareTrainingAndTestTree(
  sigCut,   # signal events
  bgCut,    # background events
  ":".join([
    "nTrain_Signal=0",
    "nTrain_Background=0",
    "SplitMode=Random",
    "NormMode=NumEvents",
    "!V"
  ]))

method = factory.BookMethod(
  ROOT.TMVA.Types.kBDT,
  "BDT",
  ":".join([
   "!H",
   "!V",
   "NTrees=850",
   "nEventsMin=150",
   "MaxDepth=3",
   "BoostType=AdaBoost",
   "AdaBoostBeta=0.5",
   "SeparationType=GiniIndex",
   "nCuts=20",
   "PruneMethod=NoPruning"
  ]))

factory.TrainAllMethods()
factory.TestAllMethods()
factory.EvaluateAllMethods()

print 'BDTs trained using ROOT TMVA'

# ------------------------------------
# PLOT HISTOGRAM OF SIGNAL VS. BACKGROUND 
# TO SHOW FEASIBILITY OF SEPARATION
# ------------------------------------

c1 = ROOT.TCanvas("c1","c1",800,800);

# fill histograms for signal and background from the test sample tree
ROOT.TestTree.Draw("BDT>>hSig(220,-1.1,1.1)","classID == 1","goff")  # signal
ROOT.TestTree.Draw("BDT>>hBg(220,-1.1,1.1)","classID == 0", "goff")  # background

ROOT.hSig.SetLineColor(ROOT.kBlue); ROOT.hSig.SetLineWidth(2)  # signal histogram
ROOT.hBg.SetLineColor(ROOT.kRed); ROOT.hBg.SetLineWidth(2)   # background histogram

# use a THStack to show both histograms
hs = ROOT.THStack("hs","SUSY Signal (Blue) vs. ttj Background (Red)")
hs.Add(ROOT.hSig)
hs.Add(ROOT.hBg)
hs.Draw()

# legend = ROOT.TLegend(0.4,0.6,0.89,0.89);
# legend.AddEntry(ROOT.hSig,"Signal")
# legend.AddEntry(ROOT.hBg,"Background")
# legend.Draw()

c1.SaveAs("plots/bdt-separation.png")

raw_input("Press any key to close.")

exit(0)

print 'APPLY CLASSIFIER TO NEW INSTANCES'

# APPLY CLASSIFIER TO NEW INSTANCES
reader = ROOT.TMVA.Reader()
reader_variables = {}
classify = {}

# directory = 'classify-mix'
directory = 'classify-ttj-only'
# directory = 'classify-susy-only'
for v in variables:
  classify[v] = to_float_array('bdt_variables/%s/%s.txt' % (directory,v))
  reader_variables[v] = array.array('f',[0])
  reader.AddVariable(v,reader_variables[v])

reader.BookMVA("BDT", "weights/TMVAClassification_BDT.weights.xml")

outputs = []
for i in range(len(classify[variables[0]])):
  for v in variables:
    reader_variables[v] = classify[v][i]
  bdtOutput = reader.EvaluateMVA("BDT")
  outputs.append(bdtOutput)
print outputs
  
