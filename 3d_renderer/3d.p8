pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

c_white=6

-- vertex buffer
vb={
 {-1,-1, 1, 1},
 {-1, 1, 1, 1},
 { 1,-1, 1, 1},
 { 1, 1, 1, 1},
 {-1,-1,-1, 1},
 {-1, 1,-1, 1},
 { 1,-1,-1, 1},
 { 1, 1,-1, 1}
}

-- index buffer
-- 3 vertex indices + color
ib={
{3,4,1, 1},
{2,1,4, 1},
{2,5,1, 2},
{6,5,2, 2},
{6,7,5, 3},
{6,8,7, 3},
{7,1,5, 4},
{7,3,1, 4},
{8,3,7, 5},
{8,4,3, 5},
{2,8,6, 6},
{2,4,8, 6}
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
function mat_p(a, n, f)
  local h = cos(a/2)/sin(-a/2)
  local w = h*1.0
  return {
    w,0,0,0,
    0,h,0,0,
    0,0,(-f/(f-n)),1,
    0,0,(-f*n/(f-n)),0
  }
end

function mat_rot_x(a)
  return {
    1,0,0,0,
    0,cos(a),-sin(-a),0,
    0,sin(-a),cos(a),0,
    0,0,0,1
  }
end

function mat_rot_y(a)
  return {
    cos(a),0,sin(-a),0,
    0,1,0,0,
    -sin(-a),0,cos(a),0,
    0,0,0,1 
  }
end

function mat_rot_z(a)
  return {
    cos(a),-sin(-a),0,0,
    sin(-a),cos(a),0,0,
    0,0,1,0,
    0,0,0,1
  }
end

function vec3_sub(a,b)
 return {
  a[1]-b[1],
  a[2]-b[2],
  a[3]-b[3],
 }
end

function vec3_cross(a,b)
 return {
  a[2]*b[3] - a[3]*b[2],
  a[3]*b[1] - a[1]*b[3],
  a[1]*b[2] - a[2]*b[1]
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

function square(x) return x*x end

-- comparison based sorting on the y value
-- input
--  list: array of (x,y) of length 3
-- reference http://www.sunshine2k.de/coding/java/TriangleRasterization/TriangleRasterization.html
function sort_vertices(list)
  a, b, c = unpack(list)
  if a[2] > b[2] then a, b = b, a end
  if b[2] > c[2] then b, c = c, b end
  if a[2] > b[2] then a, b = b, a end
  return {a,b,c}
end

-- rasterize bottom flat triangle
function raster_top(v1,v2,v3,c)
  -- invslope
  m1 = (v2[1]-v1[1])/(v2[2]-v1[2])
  m2 = (v3[1]-v1[1])/(v3[2]-v1[2])

  cur_x1, cur_x2 = v1[1], v1[1]
  for i=v1[2],v2[2] do
    line(flr(cur_x1), i, flr(cur_x2), i, c)
    cur_x1 += m1
    cur_x2 += m2
  end
end

function raster_bot(v1,v2,v3,c)
  -- invslope
  m1 = (v3[1]-v1[1])/(v3[2]-v1[2])
  m2 = (v3[1]-v2[1])/(v3[2]-v2[2])

  cur_x1, cur_x2 = v3[1], v3[1]
  for i=v3[2],v1[2],-1 do
      line(flr(cur_x1), i, flr(cur_x2), i, c)
      cur_x1 -= m1
      cur_x2 -= m2
  end
end

function raster(tri, c)
  -- sort vertices by y value
  v1,v2,v3=unpack(sort_vertices(tri))

  -- degenerate cases with only one triangle
  if v2[2] == v3[2] then
    raster_bot(v1, v2, v3)
  elseif v1[2] == v2[2] then
    raster_top(v1, v2, v3)
  else
    -- split the triangle into two triangles
    v4={
      (v3[1]-v1[1])/(v3[2]-v1[2])*(v2[2]-v1[2])+v1[1],
      v2[2]
    } -- find the splitline
    raster_top(v1, v2, v4, c)
    raster_bot(v2, v4, v3, c)
  end
end

function _init()
  -- test for sorted_vertices
  -- verts={
  --   {1, 8},
  --   {2, 2},
  --   {3, 4},
  -- }
  -- sorted=sort_vertices(verts)
  -- for v in all(sorted) do
  --   printh(v[1]..' '..v[2]) 
  -- end
end

angle_x=0.78
angle_y=0.78
angle_z=0.78
function _update()
  -- camera controller
  angle_x += 0.01
  angle_z += 0.01
  -- angle_y += 0.01
end


function _draw()
  cls(0)

  -- transform all vertices to screen space
  trans=mat4x4_mul(
    mat_t(0.0, 0.0, 10.0),
    mat4x4_mul(
      mat_rot_y(angle_z),
      mat4x4_mul(
        mat_rot_y(angle_y),
        mat_rot_x(angle_x)
      )
    )
  )
  proj=mat_p(0.125, 1.0, 100.0)
  rot_x=mat_rot_x(1.0)
  rot_y=mat_rot_y(1.0)
  wrld_points={} -- transofmed points in worldspace
  scr_points={} -- transformed points in screenspace
  for p in all(vb) do
    tr=mat4x4_v4_mul(trans,p)
    add(wrld_points, tr)
    tr=mat4x4_v4_mul(proj,tr)
    x=-tr[1]/tr[4]*128+64
    y=-tr[2]/tr[4]*128+64
    -- z=tr[3]/tr[4]
    -- printh(x..' '..y..' '..z)
    add(scr_points, {x,y})
  end

  -- draw all faces
  for tri in all(ib) do
    -- check for backspace culling
    -- first get normal from current triangle
    p1=vec3_sub(wrld_points[tri[1]], wrld_points[tri[2]])
    p2=vec3_sub(wrld_points[tri[2]], wrld_points[tri[3]])
    n=vec3_cross(p1, p2)
    mag=sqrt(square(n[1]) + square(n[2]) + square(n[3]))

    -- only draw triangle if n is facing camera
    if n[3]/mag < -0.1 then
      for i=0,2 do
        p1=tri[i+1]
        p2=tri[(i+1)%3+1]
        p3=tri[(i+2)%3+1]
        -- border (wireframe mode)
        line(
          scr_points[p1][1], scr_points[p1][2],
          scr_points[p2][1], scr_points[p2][2]
        ) 

        -- scanline method to actually color the triangles
        -- TODO use less tokens here
        raster({
            scr_points[p1],
            scr_points[p2],
            scr_points[p3]
        }, tri[4])
      end
    end
  end
end
