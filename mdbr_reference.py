import numpy as np
import matplotlib.pyplot as plt

x_start = 0
y_start = 0
step = 1/64

def mbr(c):
    z = 0
    n = 0

    while abs(z.real) < 2 and abs(z.imag) < 2 and n < 255:
        #print(f'{n} {z}')
        z = z**2 + c
        n += 1

    return n

steps = np.arange(0, 64)
N = np.zeros((64, 64))

for x in range(0, 64):
    for y in range(0, 64):
        N[x, y] = mbr((x_start + x*step)+1j*(y_start + y*step))

plt.imshow(N)
plt.show()
