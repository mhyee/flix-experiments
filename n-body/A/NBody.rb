require 'benchmark'

# n-body, from the Computer Language Benchmarks Game
# http://benchmarksgame.alioth.debian.org/u64q/nbody-description.html#nbody

# This implementation is a close translation of the Flix program, which was loosely based on:
# http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=java&id=2

N = 100000

Pi = 3.141592653589793;
SolarMass = 4.0 * (Pi * Pi);
DaysPerYear = 365.24;

Body = Struct.new(:x, :y, :z, :vx, :vy, :vz, :m) do
  def to_ary
    [x, y, z, vx, vy, vz, m]
  end
end

SolarSystem = Struct.new(:sun, :jupiter, :saturn, :uranus, :neptune) do
  def to_ary
    [sun, jupiter, saturn, uranus, neptune]
  end
end

def distance(dx, dy, dz)
  ((dx * dx) + (dy * dy) + (dz * dz)) ** 0.5
end

def offsetMomentum(b, px, py, pz)
  Body.new(b.x, b.y, b.z, -px / SolarMass, -py / SolarMass, -pz / SolarMass, b.m)
end

def getSpeedSq(b)
  x, y, z, vx, vy, vz, m = b.to_ary
  (vx * vx) + (vy * vy) + (vz * vz)
end

def getEnergy(b)
  0.5 * b.m * getSpeedSq(b)
end

def moveBody(b, dt)
  x, y, z, vx, vy, vz, m = b.to_ary
  Body.new(x + (dt * vx), y + (dt * vy), z + (dt * vz), vx, vy, vz, m)
end

def advanceBody(b, dx, dy, dz, delta)
  x, y, z, vx, vy, vz, m = b.to_ary
  Body.new(x, y, z, vx + (dx * delta), vy + (dy * delta), vz + (dz * delta), m)
end

def advanceHelper(b1, b2, dt)
  x1, y1, z1, vx1, vy1, vz1, m1 = b1.to_ary
  x2, y2, z2, vx2, vy2, vz2, m2 = b2.to_ary
  dx = x1 - x2
  dy = y1 - y2
  dz = z1 - z2
  d = distance(dx, dy, dz)
  mag = dt / (d * d * d)
  newB1 = advanceBody(b1, dx, dy, dz, -b2.m * mag)
  newB2 = advanceBody(b2, dx, dy, dz, b1.m * mag)
  [newB1, newB2]
end

def advance(s, dt)
  sun0, jupiter0, saturn0, uranus0, neptune0 = s.to_ary
  sun1, jupiter1 = advanceHelper(sun0, jupiter0, dt)
  sun2, saturn1 = advanceHelper(sun1, saturn0, dt)
  sun3, uranus1 = advanceHelper(sun2, uranus0, dt)
  sun4, neptune1 = advanceHelper(sun3, neptune0, dt)
  jupiter2, saturn2 = advanceHelper(jupiter1, saturn1, dt)
  jupiter3, uranus2 = advanceHelper(jupiter2, uranus1, dt)
  jupiter4, neptune2 = advanceHelper(jupiter3, neptune1, dt)
  saturn3, uranus3 = advanceHelper(saturn2, uranus2, dt)
  saturn4, neptune3 = advanceHelper(saturn3, neptune2, dt)
  uranus4, neptune4 = advanceHelper(uranus3, neptune3, dt)
  SolarSystem.new(moveBody(sun4, dt), moveBody(jupiter4, dt), moveBody(saturn4, dt), moveBody(uranus4, dt), moveBody(neptune4, dt))
end

def energyHelper(b1, b2)
  x1, y1, z1, vx1, vy1, vz1, m1 = b1.to_ary
  x2, y2, z2, vx2, vy2, vz2, m2 = b2.to_ary
  dx = x1 - x2
  dy = y1 - y2
  dz = z1 - z2
  (m1 * m2) / distance(dx, dy, dz)
end

def energy(s)
  sun, jupiter, saturn, uranus, neptune = s.to_ary
  posE = getEnergy(sun) + getEnergy(jupiter) + getEnergy(saturn) + getEnergy(uranus) + getEnergy(neptune)
  negE = energyHelper(sun, jupiter) + energyHelper(sun, saturn) + energyHelper(sun, uranus) + energyHelper(sun, neptune) +
         energyHelper(jupiter, saturn) + energyHelper(jupiter, uranus) + energyHelper(jupiter, neptune) +
         energyHelper(saturn, uranus) + energyHelper(saturn, neptune) +
         energyHelper(uranus, neptune)
  posE - negE
end

def step(s, e, i)
  if i == 0 then e
  else
    s1 = advance(s, 0.01)
    step(s1, energy(s1), i - 1)
  end
end

def initJupiter
  Body.new(
    4.84143144246472090,
    -1.16032004402742839,
    -0.103622044471123109,
    0.00166007664274403694 * DaysPerYear,
    0.00769901118419740425 * DaysPerYear,
    -0.0000690460016972063023 * DaysPerYear,
    0.000954791938424326609 * SolarMass)
end
def initSaturn
  Body.new(
    8.34336671824457987,
    4.12479856412430479,
    -0.403523417114321381,
    -0.00276742510726862411 * DaysPerYear,
    0.00499852801234917238 * DaysPerYear,
    0.0000230417297573763929 * DaysPerYear,
    0.000285885980666130812 * SolarMass)
end
def initUranus
  Body.new(
    12.8943695621391310,
    -15.1111514016986312,
    -0.223307578892655734,
    0.00296460137564761618 * DaysPerYear,
    0.00237847173959480950 * DaysPerYear,
    -0.0000296589568540237556 * DaysPerYear,
    0.0000436624404335156298 * SolarMass)
end
def initNeptune
  Body.new(
    15.3796971148509165,
    -25.9193146099879641,
    0.179258772950371181,
    0.00268067772490389322 * DaysPerYear,
    0.00162824170038242295 * DaysPerYear,
    -0.0000951592254519715870 * DaysPerYear,
    0.0000515138902046611451 * SolarMass)
end
def initSun
  Body.new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SolarMass)
end

def initialSystem()
  sunX, sunY, sunZ, sunVx, sunVy, sunVz, sunM = initSun.to_ary
  jupiterX, jupiterY, jupiterZ, jupiterVx, jupiterVy, jupiterVz, jupiterM = initJupiter.to_ary
  saturnX, saturnY, saturnZ, saturnVx, saturnVy, saturnVz, saturnM = initSaturn.to_ary
  uranusX, uranusY, uranusZ, uranusVx, uranusVy, uranusVz, uranusM = initUranus.to_ary
  neptuneX, neptuneY, neptuneZ, neptuneVx, neptuneVy, neptuneVz, neptuneM = initNeptune.to_ary
  px = (sunVx * sunM) +
       (jupiterVx * jupiterM) +
       (saturnVx * saturnM) +
       (uranusVx * uranusM) +
       (neptuneVx * neptuneM)
  py = (sunVy * sunM) +
       (jupiterVy * jupiterM) +
       (saturnVy * saturnM) +
       (uranusVy * uranusM) +
       (neptuneVy * neptuneM)
  pz = (sunVz * sunM) +
       (jupiterVz * jupiterM) +
       (saturnVz * saturnM) +
       (uranusVz * uranusM) +
       (neptuneVz * neptuneM)
  sun = offsetMomentum(initSun, px, py, pz)
  SolarSystem.new(sun, initJupiter, initSaturn, initUranus, initNeptune)
end

def run(i)
  step(initialSystem, energy(initialSystem), i)
end

init = nil
result = nil
time = Benchmark.realtime do
  s = SolarSystem.new
  init = run(0)
  result = run(N)
end

puts "Time: #{(time * 1000).round} ms"
puts "Initial: #{init}"
puts "Result:  #{result}"

