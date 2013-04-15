susy = open('/Users/mukul/physics-data/100t400_8TeV-55.txt')
ttj = open('/Users/mukul/Dropbox/Rice/2012 Fall/Thesis/data/ttj006f38-9.txt')

print 'Outputting to mixed file.'
output = open('classify.txt', 'w')
line = ttj.readline()
N = 0
while line != '':
  N += 1
  output.write(susy.readline())
  output.write(line)
  line = ttj.readline()
print 'Done. Read %d lines' % N

print 'Closing buffers.'
for buff in [susy, ttj, output]:
  buff.close()