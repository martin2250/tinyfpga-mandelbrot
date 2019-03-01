x_start = 0
y_start = 0
step = 1/64

Q = 10


def mbr(c):
    z = 0
    n = 0

    while abs(z.real) < 2 and abs(z.imag) < 2 and n < 255:
        print(f'{n} {z}')
        z = z**2 + c
        n += 1

    return n

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

#to_fixed(1/64)

x = 19
y = 0

mbr((x_start + x*step)+1j*(y_start + y*step))
