pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

c_white=6

square={
  {
    {-1,-1, 0, 1},
    { 1,-1, 0, 1},
    {-1, 1, 0, 1},
  },
  {
    { 1,-1, 0, 1},
    { 1, 1, 0, 1},
    {-1, 1, 0, 1},
  }
}

-- Construct a translation matrix
function mat_t(x, y, z)
 return {
  1,0,0,x,
  0,1,0,y,
  0,0,1,z,
  0,0,0,1  
 }
end

-- Construct projection matrix
-- based off of https://www.youtube.com/watch?v=ih20l3pJoeU
-- inputs
--  a: aspect ratio
--  vn: near clipping plane
--  vf: far clipping plane
--  vtheta: viewing angle
function mat_p(a, vn, vf)
  f=1/tan(vtheta/2)
  return {
    a*f,0,0,0,
    0,f,0,0,
    0,0,q,1,
    0,0,-vn*q,0
  }
end

-- Multiply two 4x4 matrices
function mat4x4_mul(a, b)
  return {
    a[1]*b[1]+a[2]*b[5]+a[3]*b[9]+a[4]*b[13],
    a[1]*b[2]+a[2]*b[6]+a[3]*b[10]+a[4]*b[14],
    a[1]*b[3]+a[2]*b[7]+a[3]*b[11]+a[4]*b[15],
    a[1]*b[4]+a[2]*b[8]+a[3]*b[12]+a[4]*b[16],
    
    a[5]*b[1]+a[6]*b[5]+a[7]*b[9]+a[8]*b[13],
    a[5]*b[2]+a[6]*b[6]+a[7]*b[10]+a[8]*b[14],
    a[5]*b[3]+a[6]*b[7]+a[7]*b[11]+a[8]*b[15],
    a[5]*b[4]+a[6]*b[8]+a[7]*b[12]+a[8]*b[16],
    
    a[9]*b[1]+a[10]*b[5]+a[11]*b[9]+a[12]*b[13],
    a[9]*b[2]+a[10]*b[6]+a[11]*b[10]+a[12]*b[14],
    a[9]*b[3]+a[10]*b[7]+a[11]*b[11]+a[12]*b[15],
    a[9]*b[4]+a[10]*b[8]+a[11]*b[12]+a[12]*b[16],
    
    a[13]*b[1]+a[14]*b[5]+a[15]*b[9]+a[16]*b[13],
    a[13]*b[2]+a[14]*b[6]+a[15]*b[10]+a[16]*b[14],
    a[13]*b[3]+a[14]*b[7]+a[15]*b[11]+a[16]*b[15],
    a[13]*b[4]+a[14]*b[8]+a[15]*b[12]+a[16]*b[16],
  }
end

-- Multiply 4x4 Matrix with Vector4
function mat4x4_v4_mul(m,p)
 return {
  m[1]*p[1]+m[2]*p[2]+m[3]*p[3]+m[4]*p[4],
  m[5]*p[1]+m[6]*p[2]+m[7]*p[3]+m[8]*p[4],     
  m[9]*p[1]+m[10]*p[2]+m[11]*p[3]+m[12]*p[4],
  m[13]*p[1]+m[14]*p[2]+m[15]*p[3]+m[16]*p[4]
 }
end

function tan(a) return sin(a)/cos(a) end

function _init()
end

function _update()
  -- transform all vertices to screen space
  trans=mat_t(0.0, 0.0, 10.0)
  proj=mat_p(a, 0.125, 1.0, vtheta)
  mvp=mat4x4_mul(trans, proj)
  for triangle in all(square) do
    for p in all(triangle) do
      tr=mat4x4_v4_mul(mvp,p)
      printh(tr[4])
      x=tr[1]
      y=tr[2]
      z=tr[3]
      printh(x..' '..y..' '..z)
    end
  end
end

function _draw()
  cls(0)
end
