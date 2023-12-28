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

size = 500
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

elif sys.argv[1] == "snn":
  for i in range(size):
    a = -random.randint(0,100)
    b = -random.randint(0,100)

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

elif sys.argv[1] == "lpn":
  for i in range(size):
    a = random.randint(65536,2**31-1)
    b = -random.randint(65536,2**31-1)

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "lnp":
  for i in range(size):
    a = -random.randint(65536,2**31-1)
    b = random.randint(65536,2**31-1)

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "lnn":
  for i in range(size):
    a = -random.randint(65536,2**31-1)
    b = -random.randint(65536,2**31-1)

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "low-mask-a":
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

    a = a & 0xfffff000
    b = b & 0xffffffff

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "low-mask-b":
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

    a = a & 0xffffffff
    b = b & 0xfffff000

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "low-mask":
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

    a = a & 0xfffff000
    b = b & 0xfffff000

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "mid-mask-a":
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

    a = a & 0xff000fff
    b = b & 0xffffffff

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "mid-mask-b":
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

    a = a & 0xffffffff
    b = b & 0xff000fff

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "mid-mask":
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

    a = a & 0xff000fff
    b = b & 0xff000fff

    in0.append(a)
    in1.append(b)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "sparse-a":
  bin_weights = (10, 1)
  for i in range(size):
    a = 0
    b = random.randint(-(2**31),2**31-1)
    for j in range(32):
      a = (a << 1) + random.choices([0,1], weights=bin_weights)[0]

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "sparse-b":
  bin_weights = (10, 1)
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = 0
    for j in range(32):
      b = (b << 1) + random.choices([0,1], weights=bin_weights)[0]

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "sparse":
  bin_weights = (10, 1)
  for i in range(size):
    a = 0
    b = 0
    for j in range(32):
      a = (a << 1) + random.choices([0,1], weights=bin_weights)[0]
      b = (b << 1) + random.choices([0,1], weights=bin_weights)[0]

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "dense-a":
  bin_weights = (1, 10)
  for i in range(size):
    a = 0
    b = random.randint(-(2**31),2**31-1)
    for j in range(32):
      a = (a << 1) + random.choices([0,1], weights=bin_weights)[0]

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "dense-b":
  bin_weights = (1, 10)
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = 0
    for j in range(32):
      b = (b << 1) + random.choices([0,1], weights=bin_weights)[0]

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "dense":
  bin_weights = (1, 10)
  for i in range(size):
    a = 0
    b = 0
    for j in range(32):
      a = (a << 1) + random.choices([0,1], weights=bin_weights)[0]
      b = (b << 1) + random.choices([0,1], weights=bin_weights)[0]

    in0.append(a & 0xffffffff)
    in1.append(b & 0xffffffff)
    out.append((a * b) & 0xffffffff)

  print_dataset(in0, in1, out)

elif sys.argv[1] == "uniform":
  bin_weights = (1, 10)
  for i in range(size):
    a = random.randint(-(2**31),2**31-1)
    b = random.randint(-(2**31),2**31-1)

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

