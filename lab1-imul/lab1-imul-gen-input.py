#=========================================================================
# plab1-imul-input-gen
#=========================================================================
# Script to generate inputs for integer multiplier unit.

import fractions
import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------

def print_dataset( in0, in1, out ):

  for i in range(len(in0)):

    print ("init( {:0>2}, 32'h{:0>8x}, 32'h{:0>8x}, 32'h{:0>8x} );" \
      .format( i, in0[i], in1[i], out[i] ))

#-------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------

'''
try:
  size = int(sys.argv[2])
except:
  size = 10
'''

size = 50
print ("num_inputs =", size, ";")

in0 = []
in1 = []
out = []

#-------------------------------------------------------------------------
# small dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "small":
  for i in range(size):

    a = random.randint(0,100)
    b = random.randint(0,100)

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

# Add code to generate other random datasets here


#-------------------------------------------------------------------------
# small postive * negative dataset
#-------------------------------------------------------------------------
elif sys.argv[1] == "spn": # small positive * negative
  for i in range(size):
      a = random.randint(0,100)
      b = -random.randint(0,100)

      in0.append(a & 0xffffffff)
      in1.append(b & 0xffffffff)
      out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

#-------------------------------------------------------------------------
# small negative * positive dataset
#-------------------------------------------------------------------------
elif sys.argv[1] == "snp":
  for i in range(size):
      a = -random.randint(0,100)
      b = random.randint(0,100)

      in0.append(a & 0xffffffff)
      in1.append(b & 0xffffffff)
      out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

#-------------------------------------------------------------------------
# large positive  * positive dataset
#-------------------------------------------------------------------------
elif sys.argv[1] == "lpp":
  for i in range(size):
      a = random.randint(65536,2**31-1)
      b = random.randint(65536,2**31-1)

      in0.append(a & 0xffffffff)
      in1.append(b & 0xffffffff)
      out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)


#-------------------------------------------------------------------------
# Unrecognized dataset
#-------------------------------------------------------------------------

else:
  sys.stderr.write("unrecognized command line argument\n")
  exit(1)

exit(0)

