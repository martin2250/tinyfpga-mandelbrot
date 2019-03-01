import serial
import numpy as np
import matplotlib.pyplot as plt

ser = serial.Serial('COM6', 1000000)

x_start = 0
y_start = 0
step = 1/64

Q = 10

def to_fixed(num):
    nums = num * (2**Q)
    sign = num < 0
    numi = int(abs(nums))

    if numi > (2**15 - 1):
        print(f'number {num} is too large')

    b1 = numi & 0xFF
    b2 = (numi >> 8) & 0x7F

    if sign:
        b2 |= (1 << 7)

    print([b2, b1])

    return bytearray([b2, b1])

data = b'\x01'
data += to_fixed(x_start)
data += to_fixed(y_start)
data += to_fixed(step)

print(data)

ser.write(data)

n = 0

data = b''

while n < 4096:
    x = ser.read(32)
    n += len(x)
    data += x

data = np.frombuffer(data, dtype=np.uint8)
data = data.reshape((64, 64))
plt.imshow(data)
plt.show()
