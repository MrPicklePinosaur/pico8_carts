pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()

end

width=0
num_stripe=8
function _update()
  width = flr(abs(sin(1/4*time()))*4)+8
end

function _draw()
  cls(0)
  for j=0, num_stripe-1 do
    for i=0,width do
      if i < 2 then
        fillp(0b0000000000000000)
      elseif i < 4 then
        fillp(0b0000010100000101)
      elseif i < 6 then
        fillp(0b1010010110100101)
      elseif i < 8 then
        fillp(0b1010111110101111)
      end
      local x_off = (time()*16+j*flr(256/num_stripe)) % 256 - 128
      line(x_off+i, 0, x_off+148, 148-i, 1)
      line(x_off-20, i-20, x_off+128-i, 128, 1)
    end
  end

end
