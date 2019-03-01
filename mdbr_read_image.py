import serial
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image

ser = serial.Serial('COM6', 500000, timeout=0.5)

Q = 24

def get_block(x_start, y_start, step):
	def to_fixed(num):
		nums = num * (2**Q)
		sign = num < 0
		numi = int(abs(nums))

		if numi > (2**26 - 1):
			print(f'number {num} is too large')

		b1 = numi & 0xFF
		b2 = (numi >> 8) & 0xFF
		b3 = (numi >> 16) & 0xFF
		b4 = (numi >> 24) & 0x1F

		if sign:
			b4 |= (1 << 5)

		return bytearray([b4, b3, b2, b1])

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

n_blocks_x = 64
n_blocks_y = 64

x_start = 0.244345
x_end = 0.24758
y_start = 0.56618

step_block = (x_end - x_start)/(n_blocks_x)
step = step_block/64

step_fixed = int(2**Q * step)
step = step_fixed /2**Q
step_block = step * 64

print('fixed point step size:', step_fixed)

frame = np.zeros((64*n_blocks_x, 64*n_blocks_y))

done = 0

for i in range(n_blocks_x):
	for j in range(n_blocks_y):
		print(f'{done}/{n_blocks_x*n_blocks_y}')
		done += 1
		frame[i*64:(i+1)*64, j*64:(j+1)*64] = get_block(x_start + i*step_block, y_start + j*step_block, step)

frame = np.rot90(frame)

rgbframe = np.zeros((64*n_blocks_x, 64*n_blocks_y, 3))

for i in range(rgbframe.shape[0]):
	for j in range(rgbframe.shape[1]):
		if frame[i, j] == 255:
			rgbframe[i, j] = [0, 0, 0]
		else:
			n = frame[i, j] / 40
			rgbframe[i, j] = [0.5 + 0.5*np.sin(n), 0.5 + 0.5*np.sin(n + (np.pi/3)),0.5 + 0.5* np.sin(n + (2*np.pi/3))]

matplotlib.image.imsave(f'mandelbrot_{n_blocks_x*64}x{n_blocks_x*64}_{x_start}_{x_end}_{y_start}.png', rgbframe)

plt.imshow(rgbframe)
plt.show()
