import serial
import numpy as np
import matplotlib.pyplot as plt

ser = serial.Serial('COM4', 500000, timeout=0.5)

#x_start = 0
#y_start = 0
#step = 0.2/64

Q = 10

def get_block(x_start, y_start, step):
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

        return bytearray([b2, b1])

    data = b'\x01'
    data += to_fixed(x_start)
    data += to_fixed(y_start)
    data += to_fixed(step)

    ser.write(data)

    n = 0

    data = b''

    while n < 4096:
        x = ser.read(4096-n)
        n += len(x)
        data += x
        print(n)

    data = np.frombuffer(data, dtype=np.uint8)
    data = data.reshape((64, 64))

    return data.T

n_blocks_x = 16
n_blocks_y = 16

x_start = 0
y_start = 0
x_end = 1

step_block = (x_end - x_start)/(n_blocks_x)
step = step_block/64

frame = np.zeros((64*n_blocks_x, 64*n_blocks_y))

for i in range(n_blocks_x):
    for j in range(n_blocks_y):
        frame[i*64:(i+1)*64, j*64:(j+1)*64] = get_block(x_start + i*step_block, y_start + j*step_block, step)


plt.imshow(frame)
plt.show()
