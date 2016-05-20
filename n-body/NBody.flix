namespace NBody {

    // n-body, from the Computer Language Benchmarks Game
    // http://benchmarksgame.alioth.debian.org/u64q/nbody-description.html#nbody

    // This implementation is loosely based on:
    // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=java&id=2

    def numSteps(dummy: Int): Int = 100000

    def pi: Float = 3.141592653589793
    def solarMass: Float = 4.0 * (pi * pi)
    def daysPerYear: Float = 365.24

    enum Body { case B(Float, Float, Float, Float, Float, Float, Float) }
    def body(x: Float, y: Float, z: Float, vx: Float, vy: Float, vz: Float, m: Float): Body =
      Body.B(x, y, z, vx, vy, vz, m)

    enum System { case S(Body, Body, Body, Body, Body) }
    def system(sun: Body, jupiter: Body, saturn: Body, uranus: Body, neptune: Body): System =
      System.S(sun, jupiter, saturn, uranus, neptune)

    def fst(tpl: (Body, Body)): Body = match tpl with { case (x, _) => x }
    def snd(tpl: (Body, Body)): Body = match tpl with { case (_, x) => x }

    def initJupiter: Body = body(
      4.84143144246472090,
      -1.16032004402742839,
      -0.103622044471123109,
      0.00166007664274403694 * daysPerYear,
      0.00769901118419740425 * daysPerYear,
      -0.0000690460016972063023 * daysPerYear,
      0.000954791938424326609 * solarMass)
    def initSaturn: Body = body(
      8.34336671824457987,
      4.12479856412430479,
      -0.403523417114321381,
      -0.00276742510726862411 * daysPerYear,
      0.00499852801234917238 * daysPerYear,
      0.0000230417297573763929 * daysPerYear,
      0.000285885980666130812 * solarMass)
    def initUranus: Body = body(
      12.8943695621391310,
      -15.1111514016986312,
      -0.223307578892655734,
      0.00296460137564761618 * daysPerYear,
      0.00237847173959480950 * daysPerYear,
      -0.0000296589568540237556 * daysPerYear,
      0.0000436624404335156298 * solarMass)
    def initNeptune: Body = body(
      15.3796971148509165,
      -25.9193146099879641,
      0.179258772950371181,
      0.00268067772490389322 * daysPerYear,
      0.00162824170038242295 * daysPerYear,
      -0.0000951592254519715870 * daysPerYear,
      0.0000515138902046611451 * solarMass)
    def initSun: Body = body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, solarMass)

    def offsetMomentum(b: Body, px: Float, py: Float, pz: Float): Body = match b with {
      case Body.B(x, y, z, vx, vy, vz, m) =>
        body(x, y, z, -px / solarMass, -py / solarMass, -pz / solarMass, m)
    }

    def getX(b: Body): Float = match b with { case Body.B(x, _, _, _, _, _, _) => x }
    def getY(b: Body): Float = match b with { case Body.B(_, y, _, _, _, _, _) => y }
    def getZ(b: Body): Float = match b with { case Body.B(_, _, z, _, _, _, _) => z }
    def getVx(b: Body): Float = match b with { case Body.B(_, _, _, vx, _, _, _) => vx }
    def getVy(b: Body): Float = match b with { case Body.B(_, _, _, _, vy, _, _) => vy }
    def getVz(b: Body): Float = match b with { case Body.B(_, _, _, _, _, vz, _) => vz }
    def getM(b: Body): Float = match b with { case Body.B(_, _, _, _, _, _, m) => m }

    def getSpeedSq(b: Body): Float = match b with { case Body.B(_, _, _, vx, vy, vz, _) => (vx * vx) + (vy * vy) + (vz * vz) }
    def getEnergy(b: Body): Float = 0.5 * getM(b) * getSpeedSq(b)
    def moveBody(b: Body, dt: Float): Body = match b with {
      case Body.B(x, y, z, vx, vy, vz, m) => body(x + (dt * vx), y + (dt * vy), z + (dt * vz), vx, vy, vz, m)
    }
    def advanceBody(b: Body, dx: Float, dy: Float, dz: Float, delta: Float): Body = match b with {
      case Body.B(x, y, z, vx, vy, vz, m) => body(x, y, z, vx + (dx * delta), vy + (dy * delta), vz + (dz * delta), m)
    }

    def initialSystem: System =
      let px = (getVx(initSun) * getM(initSun)) +
               (getVx(initJupiter) * getM(initJupiter)) +
               (getVx(initSaturn) * getM(initSaturn)) +
               (getVx(initUranus) * getM(initUranus)) +
               (getVx(initNeptune) * getM(initNeptune)) in
      let py = (getVy(initSun) * getM(initSun)) +
               (getVy(initJupiter) * getM(initJupiter)) +
               (getVy(initSaturn) * getM(initSaturn)) +
               (getVy(initUranus) * getM(initUranus)) +
               (getVy(initNeptune) * getM(initNeptune)) in
      let pz = (getVz(initSun) * getM(initSun)) +
               (getVz(initJupiter) * getM(initJupiter)) +
               (getVz(initSaturn) * getM(initSaturn)) +
               (getVz(initUranus) * getM(initUranus)) +
               (getVz(initNeptune) * getM(initNeptune)) in
      let sun = offsetMomentum(initSun, px, py, pz) in
        system(sun, initJupiter, initSaturn, initUranus, initNeptune)

    def distance(dx: Float, dy: Float, dz: Float): Float = ((dx * dx) + (dy * dy) + (dz * dz)) ** 0.5

    def advance(s: System, dt: Float): System = match s with {
      case System.S(sun0, jupiter0, saturn0, uranus0, neptune0) =>
        let r1 = advanceHelper0(sun0, jupiter0, dt) in
        let sun1 = fst(r1) in
        let jupiter1 = snd(r1) in
        let r2 = advanceHelper0(sun1, saturn0, dt) in
        let sun2 = fst(r2) in
        let saturn1 = snd(r2) in
        let r3 = advanceHelper0(sun2, uranus0, dt) in
        let sun3 = fst(r3) in
        let uranus1 = snd(r3) in
        let r4 = advanceHelper0(sun3, neptune0, dt) in
        let sun4 = fst(r4) in
        let neptune1 = snd(r4) in
        let r5 = advanceHelper0(jupiter1, saturn1, dt) in
        let jupiter2 = fst(r5) in
        let saturn2 = snd(r5) in
        let r6 = advanceHelper0(jupiter2, uranus1, dt) in
        let jupiter3 = fst(r6) in
        let uranus2 = snd(r6) in
        let r7 = advanceHelper0(jupiter3, neptune1, dt) in
        let jupiter4 = fst(r7) in
        let neptune2 = snd(r7) in
        let r8 = advanceHelper0(saturn2, uranus2, dt) in
        let saturn3 = fst(r8) in
        let uranus3 = snd(r8) in
        let r9 = advanceHelper0(saturn3, neptune2, dt) in
        let saturn4 = fst(r9) in
        let neptune3 = snd(r9) in
        let r10 = advanceHelper0(uranus3, neptune3, dt) in
        let uranus4 = fst(r10) in
        let neptune4 = snd(r10) in
          system(moveBody(sun4, dt), moveBody(jupiter4, dt), moveBody(saturn4, dt), moveBody(uranus4, dt), moveBody(neptune4, dt))
    }

    def advanceHelper0(b1: Body, b2: Body, dt: Float): (Body, Body) = match (b1, b2) with {
      case (Body.B(x1, y1, z1, vx1, vy1, vz1, m1), Body.B(x2, y2, z2, vx2, vy2, vz2, m2)) =>
        let dx = x1 - x2 in
        let dy = y1 - y2 in
        let dz = z1 - z2 in
        let distance = distance(dx, dy, dz) in
        let mag = dt / (distance * distance * distance) in
        let newB1 = advanceBody(b1, dx, dy, dz, -getM(b2) * mag) in
        let newB2 = advanceBody(b2, dx, dy, dz, getM(b1) * mag) in
          (newB1, newB2)
    }

    def energy(s: System): Float = match s with {
      case System.S(sun, jupiter, saturn, uranus, neptune) =>
        let posE = getEnergy(sun) + getEnergy(jupiter) + getEnergy(saturn) + getEnergy(uranus) + getEnergy(neptune) in
        let negE = energyHelper(sun, jupiter) + energyHelper(sun, saturn) + energyHelper(sun, uranus) + energyHelper(sun, neptune) +
                   energyHelper(jupiter, saturn) + energyHelper(jupiter, uranus) + energyHelper(jupiter, neptune) +
                   energyHelper(saturn, uranus) + energyHelper(saturn, neptune) +
                   energyHelper(uranus, neptune) in
          posE - negE
    }

    def energyHelper(b1: Body, b2: Body): Float = match (b1, b2) with {
      case (Body.B(x1, y1, z1, _, _, _, m1), Body.B(x2, y2, z2, _, _, _, m2)) =>
        let dx = x1 - x2 in
        let dy = y1 - y2 in
        let dz = z1 - z2 in
          (m1 * m2) / distance(dx, dy, dz)
    }

    def run(i: Int): Float = step(initialSystem, energy(initialSystem), i)
    def step(s: System, e: Float, i: Int): Float =
      if (i == 0) e
      else let s1 = advance(s, 0.01) in
        step(s1, energy(s1), i - 1)

    rel Output(x: Int, y: Float);
    Output(0, run(0)).
    Output(numSteps(0), run(numSteps(0))).

}

