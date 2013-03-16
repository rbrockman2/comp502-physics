# ------------------------------------------
# Onkur Sen
# 
# plot_variables.py
# 
# Plots distributions of both non-angle
# and angle variables for SUSY and ttj
# events.
# ------------------------------------------

import ROOT, os

def plot_var(var):
  c1 = ROOT.TCanvas("c1","c1",800,800)

  susy = ROOT.TH1F(
    var.upper(),
    "Distribution of %s: SUSY (Blue) vs. ttj (Red)" % var.upper(),
    45, 0, 900)
  for line in open("bdt_variables/train-susy/%s.txt" % var): susy.Fill(float(line))
  susy.SetLineColor(ROOT.kBlue)
  susy.SetLineWidth(2)

  ttj = ROOT.TH1F(
    var.upper(),
    "Distribution of %s: SUSY (Blue) vs. ttj (Red)" % var.upper(),
    45, 0, 900)
  for line in open("bdt_variables/train-ttj/%s.txt" % var): ttj.Fill(float(line))
  ttj.SetLineColor(ROOT.kRed)
  ttj.SetLineWidth(2)

  hs = ROOT.THStack("hs","Distribution of %s: SUSY (Blue) vs. ttj (Red)" % var.upper())
  hs.Add(susy)
  hs.Add(ttj)
  hs.Draw()

  c1.SaveAs("plots/plot_%s.png" % var)

def plot_angle(var):
  c1 = ROOT.TCanvas("c1","c1",800,800)

  susy = ROOT.TH1F("%s_angles" % var,
    "Azimuthal Angles: SUSY (Blue) vs. ttj (Red)",
    35, 0, 3.5)
  for line in open("bdt_variables/train-susy/angles_%s.txt" % var): susy.Fill(float(line))
  susy.SetLineColor(ROOT.kBlue)
  susy.SetLineWidth(2)
  if susy.Integral()!=0: susy.Scale(1/susy.Integral())
  susy.SetMaximum(0.06)
  susy.SetLabelSize(0.05,"x")
  susy.SetXTitle("#Delta#phi"); susy.SetYTitle("Fraction / 0.1")
  susy.GetYaxis().SetTitleSize(0.05); susy.GetXaxis().SetTitleSize(0.05)
  susy.Draw()

  ttj = ROOT.TH1F("%s_angles" % var,
    "Azimuthal Angles of Bottom Quark", 35, 0, 3.5)
  for line in open("bdt_variables/train-ttj/angles_%s.txt" % var):
    ttj.Fill(float(line))
  ttj.SetLineColor(ROOT.kRed)
  ttj.SetLineWidth(2)
  if (ttj.Integral()!=0): ttj.Scale(1/ttj.Integral())
  ttj.Draw("same")

  c1.SaveAs("plots/plot_angles_%s.png" % var)

if not os.path.isdir('plots'): os.system('mkdir plots')

variables = ['m3a', 'm2a', 'm3b', 'm2b']
angles = ['b', 'j1', 'j2']

for v in variables:
  plot_var(v)
  print 'Plotted', v

for a in angles:
  plot_angle(a)
  print 'Plotted', a, 'angle'