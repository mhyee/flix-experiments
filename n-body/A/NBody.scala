object NBody {

  // n-body, from the Computer Language Benchmarks Game
  // http://benchmarksgame.alioth.debian.org/u64q/nbody-description.html#nbody

  // This implementation is a close translation of the Flix program, which was loosely based on:
  // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=java&id=2

  val N = 100000

  val pi = 3.141592653589793
  val solarMass = 4.0 * (pi * pi)
  val daysPerYear = 365.24

  case class Body(x: Double, y: Double, z: Double, vx: Double, vy: Double, vz: Double, m: Double)

  case class SolarSystem(sun: Body, jupiter: Body, saturn: Body, uranus: Body, neptune: Body)

  def distance(dx: Double, dy: Double, dz: Double): Double =
    math.pow((dx * dx) + (dy * dy) + (dz * dz), 0.5)

  def offsetMomentum(b: Body, px: Double, py: Double, pz: Double): Body = {
    val Body(x, y, z, vx, vy, vz, m) = b
    Body(x, y, z, -px / solarMass, -py / solarMass, -pz / solarMass, m)
  }

  def getM(b: Body): Double = {
    val Body(_, _, _, _, _, _, m) = b
    m
  }

  def getSpeedSq(b: Body): Double = {
    val Body(_, _, _, vx, vy, vz, _) = b
    (vx * vx) + (vy * vy) + (vz * vz)
  }

  def getEnergy(b: Body): Double = 0.5 * getM(b) * getSpeedSq(b)

  def moveBody(b: Body, dt: Double): Body = {
    val Body(x, y, z, vx, vy, vz, m) = b
    Body(x + (dt * vx), y + (dt * vy), z + (dt * vz), vx, vy, vz, m)
  }

  def advanceBody(b: Body, dx: Double, dy: Double, dz: Double, delta: Double): Body = {
    val Body(x, y, z, vx, vy, vz, m) = b
    Body(x, y, z, vx + (dx * delta), vy + (dy * delta), vz + (dz * delta), m)
  }

  def advanceHelper(b1: Body, b2: Body, dt: Double): (Body, Body) = {
    val Body(x1, y1, z1, vx1, vy1, vz1, m1) = b1
    val Body(x2, y2, z2, vx2, vy2, vz2, m2) = b2
    val dx = x1 - x2
    val dy = y1 - y2
    val dz = z1 - z2
    val d = distance(dx, dy, dz)
    val mag = dt / (d * d * d)
    val newB1 = advanceBody(b1, dx, dy, dz, -getM(b2) * mag)
    val newB2 = advanceBody(b2, dx, dy, dz, getM(b1) * mag)
    (newB1, newB2)
  }

  def advance(s: SolarSystem, dt: Double): SolarSystem = {
    val SolarSystem(sun0, jupiter0, saturn0, uranus0, neptune0) = s
    val (sun1, jupiter1) = advanceHelper(sun0, jupiter0, dt)
    val (sun2, saturn1) = advanceHelper(sun1, saturn0, dt)
    val (sun3, uranus1) = advanceHelper(sun2, uranus0, dt)
    val (sun4, neptune1) = advanceHelper(sun3, neptune0, dt)
    val (jupiter2, saturn2) = advanceHelper(jupiter1, saturn1, dt)
    val (jupiter3, uranus2) = advanceHelper(jupiter2, uranus1, dt)
    val (jupiter4, neptune2) = advanceHelper(jupiter3, neptune1, dt)
    val (saturn3, uranus3) = advanceHelper(saturn2, uranus2, dt)
    val (saturn4, neptune3) = advanceHelper(saturn3, neptune2, dt)
    val (uranus4, neptune4) = advanceHelper(uranus3, neptune3, dt)
    SolarSystem(moveBody(sun4, dt), moveBody(jupiter4, dt), moveBody(saturn4, dt), moveBody(uranus4, dt), moveBody(neptune4, dt))
  }

  def energyHelper(b1: Body, b2: Body): Double = {
    val Body(x1, y1, z1, _, _, _, m1) = b1
    val Body(x2, y2, z2, _, _, _, m2) = b2
    val dx = x1 - x2
    val dy = y1 - y2
    val dz = z1 - z2
    (m1 * m2) / distance(dx, dy, dz)
  }

  def energy(s: SolarSystem): Double = {
    val SolarSystem(sun, jupiter, saturn, uranus, neptune) = s
    val posE = getEnergy(sun) + getEnergy(jupiter) + getEnergy(saturn) + getEnergy(uranus) + getEnergy(neptune)
    val negE = energyHelper(sun, jupiter) + energyHelper(sun, saturn) + energyHelper(sun, uranus) + energyHelper(sun, neptune) +
               energyHelper(jupiter, saturn) + energyHelper(jupiter, uranus) + energyHelper(jupiter, neptune) +
               energyHelper(saturn, uranus) + energyHelper(saturn, neptune) +
               energyHelper(uranus, neptune)
    posE - negE
  }

  def step(s: SolarSystem, e: Double, i: Int): Double =
    if (i == 0) e
    else {
      val s1 = advance(s, 0.01)
      step(s1, energy(s1), i - 1)
    }

  val initJupiter = Body(
    4.84143144246472090,
    -1.16032004402742839,
    -0.103622044471123109,
    0.00166007664274403694 * daysPerYear,
    0.00769901118419740425 * daysPerYear,
    -0.0000690460016972063023 * daysPerYear,
    0.000954791938424326609 * solarMass
  )
  val initSaturn = Body (
    8.34336671824457987,
    4.12479856412430479,
    -0.403523417114321381,
    -0.00276742510726862411 * daysPerYear,
    0.00499852801234917238 * daysPerYear,
    0.0000230417297573763929 * daysPerYear,
    0.000285885980666130812 * solarMass
  )
  val initUranus = Body(
    12.8943695621391310,
    -15.1111514016986312,
    -0.223307578892655734,
    0.00296460137564761618 * daysPerYear,
    0.00237847173959480950 * daysPerYear,
    -0.0000296589568540237556 * daysPerYear,
    0.0000436624404335156298 * solarMass
  )
  val initNeptune = Body(
    15.3796971148509165,
    -25.9193146099879641,
    0.179258772950371181,
    0.00268067772490389322 * daysPerYear,
    0.00162824170038242295 * daysPerYear,
    -0.0000951592254519715870 * daysPerYear,
    0.0000515138902046611451 * solarMass
  )
  val initSun = Body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, solarMass)

  val initialSystem: SolarSystem = {
    val Body(_, _, _, sunVx, sunVy, sunVz, sunM) = initSun
    val Body(_, _, _, jupiterVx, jupiterVy, jupiterVz, jupiterM) = initJupiter
    val Body(_, _, _, saturnVx, saturnVy, saturnVz, saturnM) = initSaturn
    val Body(_, _, _, uranusVx, uranusVy, uranusVz, uranusM) = initUranus
    val Body(_, _, _, neptuneVx, neptuneVy, neptuneVz, neptuneM) = initNeptune
    val px = (sunVx * sunM) +
             (jupiterVx * jupiterM) +
             (saturnVx * saturnM) +
             (uranusVx * uranusM) +
             (neptuneVx * neptuneM)
    val py = (sunVy * sunM) +
             (jupiterVy * jupiterM) +
             (saturnVy * saturnM) +
             (uranusVy * uranusM) +
             (neptuneVy * neptuneM)
    val pz = (sunVz * sunM) +
             (jupiterVz * jupiterM) +
             (saturnVz * saturnM) +
             (uranusVz * uranusM) +
             (neptuneVz * neptuneM)
    val sun = offsetMomentum(initSun, px, py, pz)
    SolarSystem(sun, initJupiter, initSaturn, initUranus, initNeptune)
  }

  def run(i: Int): Double = step(initialSystem, energy(initialSystem), i)

  def main(args: Array[String]): Unit = {
    val start = System.nanoTime()
    val init = run(0)
    val result = run(N)
    val end = System.nanoTime()
    val elapsed = (end - start) / 1000000

    println(s"Time: $elapsed ms")
    println(s"Initial: $init")
    println(s"Result:  $result")
  }

}

