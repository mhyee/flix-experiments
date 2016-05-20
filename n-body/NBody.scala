object NBody {

  // n-body, from the Computer Language Benchmarks Game
  // http://benchmarksgame.alioth.debian.org/u64q/nbody-description.html#nbody

  // This implementation is a loose translation of the Flix program, which was loosely based on:
  // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=java&id=2

  val N = 100000

  val pi = 3.141592653589793
  val solarMass = 4.0 * (pi * pi)
  val daysPerYear = 365.24

  case class Body(x: Double, y: Double, z: Double, vx: Double, vy: Double, vz: Double, m: Double) {
    def offsetMomentum(px: Double, py: Double, pz: Double): Body =
      this.copy(vx = -px / solarMass, vy = -py / solarMass, vz = -pz / solarMass)

    def getSpeedSq: Double = (vx * vx) + (vy * vy) + (vz * vz)

    def getEnergy: Double = 0.5 * m * getSpeedSq

    def moveBody(dt: Double): Body =
      this.copy(x = x + (dt * vx), y = y + (dt * vy), z = z + (dt * vz))

    def advanceBody(dx: Double, dy: Double, dz: Double, delta: Double): Body =
      this.copy(vx = vx + (dx * delta), vy = vy + (dy * delta), vz = vz + (dz * delta))
  }

  case class SolarSystem(sun: Body, jupiter: Body, saturn: Body, uranus: Body, neptune: Body) {
    def advance(dt: Double): SolarSystem = {
      val r1 = advanceHelper(sun, jupiter, dt)
      val sun1 = r1._1
      val jupiter1 = r1._2
      val r2 = advanceHelper(sun1, saturn, dt)
      val sun2 = r2._1
      val saturn1 = r2._2
      val r3 = advanceHelper(sun2, uranus, dt)
      val sun3 = r3._1
      val uranus1 = r3._2
      val r4 = advanceHelper(sun3, neptune, dt)
      val sun4 = r4._1
      val neptune1 = r4._2
      val r5 = advanceHelper(jupiter1, saturn1, dt)
      val jupiter2 = r5._1
      val saturn2 = r5._2
      val r6 = advanceHelper(jupiter2, uranus1, dt)
      val jupiter3 = r6._1
      val uranus2 = r6._2
      val r7  = advanceHelper(jupiter3, neptune1, dt)
      val jupiter4 = r7._1
      val neptune2 = r7._2
      val r8 = advanceHelper(saturn2, uranus2, dt)
      val saturn3 = r8._1
      val uranus3= r8._2
      val r9 = advanceHelper(saturn3, neptune2, dt)
      val saturn4 = r9._1
      val neptune3 = r9._2
      val r10 = advanceHelper(uranus3, neptune3, dt)
      val uranus4 = r10._1
      val neptune4 = r10._2
      SolarSystem(sun4.moveBody(dt), jupiter4.moveBody(dt), saturn4.moveBody(dt), uranus4.moveBody(dt), neptune4.moveBody(dt))
    }

    private def advanceHelper(b1: Body, b2: Body, dt: Double): (Body, Body) = {
      val dx = b1.x - b2.x
      val dy = b1.y - b2.y
      val dz = b1.z - b2.z
      val d = distance(dx, dy, dz)
      val mag = dt / (d * d * d)
      val newB1 = b1.advanceBody(dx, dy, dz, -b2.m * mag)
      val newB2 = b2.advanceBody(dx, dy, dz, b1.m * mag)
      (newB1, newB2)
    }

    def energy: Double = {
      val posE = sun.getEnergy + jupiter.getEnergy + saturn.getEnergy + uranus.getEnergy + neptune.getEnergy
      val negE = energyHelper(sun, jupiter) + energyHelper(sun, saturn) + energyHelper(sun, uranus) + energyHelper(sun, neptune) +
                 energyHelper(jupiter, saturn) + energyHelper(jupiter, uranus) + energyHelper(jupiter, neptune) +
                 energyHelper(saturn, uranus) + energyHelper(saturn, neptune) +
                 energyHelper(uranus, neptune)
      posE - negE
    }

    private def energyHelper(b1: Body, b2: Body): Double = {
      val dx = b1.x - b2.x
      val dy = b1.y - b2.y
      val dz = b1.z - b2.z
      (b1.m * b2.m) / distance(dx, dy, dz)
    }

    def step(i: Int): Double = {
      var x = 0
      var s = this
      while (x < i) {
        s = s.advance(0.01)
        x += 1
      }
      s.energy
    }
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
    val px = (initSun.vx * initSun.m) +
             (initJupiter.vx * initJupiter.m) +
             (initSaturn.vx * initSaturn.m) +
             (initUranus.vx * initUranus.m) +
             (initNeptune.vx * initNeptune.m)
    val py = (initSun.vy * initSun.m) +
             (initJupiter.vy * initJupiter.m) +
             (initSaturn.vy * initSaturn.m) +
             (initUranus.vy * initUranus.m) +
             (initNeptune.vy * initNeptune.m)
    val pz = (initSun.vz * initSun.m) +
             (initJupiter.vz * initJupiter.m) +
             (initSaturn.vz * initSaturn.m) +
             (initUranus.vz * initUranus.m) +
             (initNeptune.vz * initNeptune.m)
    val sun = initSun.offsetMomentum(px, py, pz)
    SolarSystem(sun, initJupiter, initSaturn, initUranus, initNeptune)
  }

  def distance(dx: Double, dy: Double, dz: Double): Double =
    math.pow((dx * dx) + (dy * dy) + (dz * dz), 0.5)

  def run(i: Int): Double = initialSystem.step(i)

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

