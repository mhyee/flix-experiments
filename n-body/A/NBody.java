class NBody {

    // n-body, from the Computer Language Benchmarks Game
    // http://benchmarksgame.alioth.debian.org/u64q/nbody-description.html#nbody

    // This implementation is a close translation of the Flix program, which was loosely based on:
    // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=java&id=2

    public static final int N = 100000;

    public static final double pi = 3.141592653589793;
    public static final double solarMass = 4.0 * (pi * pi);
    public static final double daysPerYear = 365.24;

    public static double distance(double dx, double dy, double dz) {
        return java.lang.Math.pow((dx * dx) + (dy * dy) + (dz * dz), 0.5);
    }

    public static Body offsetMomentum(Body b, double px, double py, double pz) {
        return new Body(b.x, b.y, b.z, -px / solarMass, -py / solarMass,-pz / solarMass, b.m);
    }

    public static double getSpeedSq(Body b) {
        return (b.vx * b.vx) + (b.vy * b.vy) + (b.vz * b.vz);
    }

    public static double getEnergy(Body b) {
        return 0.5 * b.m * getSpeedSq(b);
    }

    public static Body moveBody(Body b, double dt) {
        return new Body(b.x + (dt * b.vx), b.y + (dt * b.vy), b.z + (dt * b.vz), b.vx, b.vy, b.vz, b.m);
    }

    public static Body advanceBody(Body b, double dx, double dy, double dz, double delta) {
        return new Body(b.x, b.y, b.z, b.vx + (dx * delta), b.vy + (dy * delta), b.vz + (dz * delta), b.m);
    }

    public static Body[] advanceHelper(Body b1, Body b2, double dt) {
        double dx = b1.x - b2.x;
        double dy = b1.y - b2.y;
        double dz = b1.z - b2.z;
        double d = distance(dx, dy, dz);
        double mag = dt / (d * d * d);
        Body newB1 = advanceBody(b1, dx, dy, dz, -b2.m * mag);
        Body newB2 = advanceBody(b2, dx, dy, dz, b1.m * mag);
        return new Body[] {newB1, newB2};
    }

    public static SolarSystem advance(SolarSystem s, double dt) {
        Body[] r1 = advanceHelper(s.sun, s.jupiter, dt);
        Body sun1 = r1[0];
        Body jupiter1 = r1[1];
        Body[] r2 = advanceHelper(sun1, s.saturn, dt);
        Body sun2 = r2[0];
        Body saturn1 = r2[1];
        Body[] r3 = advanceHelper(sun2, s.uranus, dt);
        Body sun3 = r3[0];
        Body uranus1 = r3[1];
        Body[] r4 = advanceHelper(sun3, s.neptune, dt);
        Body sun4 = r4[0];
        Body neptune1 = r4[1];
        Body[] r5 = advanceHelper(jupiter1, saturn1, dt);
        Body jupiter2 = r5[0];
        Body saturn2 = r5[1];
        Body[] r6 = advanceHelper(jupiter2, uranus1, dt);
        Body jupiter3 = r6[0];
        Body uranus2 = r6[1];
        Body[] r7 = advanceHelper(jupiter3, neptune1, dt);
        Body jupiter4 = r7[0];
        Body neptune2 = r7[1];
        Body[] r8 = advanceHelper(saturn2, uranus2, dt);
        Body saturn3 = r8[0];
        Body uranus3 = r8[1];
        Body[] r9 = advanceHelper(saturn3, neptune2, dt);
        Body saturn4 = r9[0];
        Body neptune3 = r9[1];
        Body[] r10 = advanceHelper(uranus3, neptune3, dt);
        Body uranus4 = r10[0];
        Body neptune4 = r10[1];
        return new SolarSystem(moveBody(sun4, dt), moveBody(jupiter4, dt), moveBody(saturn4, dt), moveBody(uranus4, dt), moveBody(neptune4, dt));
    }

    public static double energyHelper(Body b1, Body b2) {
        double dx = b1.x - b2.x;
        double dy = b1.y - b2.y;
        double dz = b1.z - b2.z;
        return (b1.m * b2.m) / distance(dx, dy, dz);
    }

    public static double energy(SolarSystem s) {
        Body sun = s.sun;
        Body jupiter = s.jupiter;
        Body saturn = s.saturn;
        Body uranus = s.uranus;
        Body neptune = s.neptune;
        double posE = getEnergy(sun) + getEnergy(jupiter) + getEnergy(saturn) + getEnergy(uranus) + getEnergy(neptune);
        double negE = energyHelper(sun, jupiter) + energyHelper(sun, saturn) + energyHelper(sun, uranus) + energyHelper(sun, neptune) +
                      energyHelper(jupiter, saturn) + energyHelper(jupiter, uranus) + energyHelper(jupiter, neptune) +
                      energyHelper(saturn, uranus) + energyHelper(saturn, neptune) +
                      energyHelper(uranus, neptune);
        return posE - negE;
    }

    public static double step(SolarSystem s, double e, int i) {
        if (i == 0) {
            return e;
        } else {
            SolarSystem s1 = advance(s, 0.01);
            return step(s1, energy(s1), i - 1);
        }
    }

    public static Body initJupiter = new Body(
        4.84143144246472090,
        -1.16032004402742839,
        -0.103622044471123109,
        0.00166007664274403694 * daysPerYear,
        0.00769901118419740425 * daysPerYear,
        -0.0000690460016972063023 * daysPerYear,
        0.000954791938424326609 * solarMass);
    public static Body initSaturn = new Body(
        8.34336671824457987,
        4.12479856412430479,
        -0.403523417114321381,
        -0.00276742510726862411 * daysPerYear,
        0.00499852801234917238 * daysPerYear,
        0.0000230417297573763929 * daysPerYear,
        0.000285885980666130812 * solarMass);
    public static Body initUranus = new Body(
        12.8943695621391310,
        -15.1111514016986312,
        -0.223307578892655734,
        0.00296460137564761618 * daysPerYear,
        0.00237847173959480950 * daysPerYear,
        -0.0000296589568540237556 * daysPerYear,
        0.0000436624404335156298 * solarMass);
    public static Body initNeptune = new Body(
        15.3796971148509165,
        -25.9193146099879641,
        0.179258772950371181,
        0.00268067772490389322 * daysPerYear,
        0.00162824170038242295 * daysPerYear,
        -0.0000951592254519715870 * daysPerYear,
        0.0000515138902046611451 * solarMass);
    public static Body initSun = new Body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, solarMass);

    public static SolarSystem initialSystem() {
        double px = (initSun.vx * initSun.m) +
                    (initJupiter.vx * initJupiter.m) +
                    (initSaturn.vx * initSaturn.m) +
                    (initUranus.vx * initUranus.m) +
                    (initNeptune.vx * initNeptune.m);
        double py = (initSun.vy * initSun.m) +
                    (initJupiter.vy * initJupiter.m) +
                    (initSaturn.vy * initSaturn.m) +
                    (initUranus.vy * initUranus.m) +
                    (initNeptune.vy * initNeptune.m);
        double pz = (initSun.vz * initSun.m) +
                    (initJupiter.vz * initJupiter.m) +
                    (initSaturn.vz * initSaturn.m) +
                    (initUranus.vz * initUranus.m) +
                    (initNeptune.vz * initNeptune.m);
        Body sun = offsetMomentum(initSun, px, py, pz);
        return new SolarSystem(sun, initJupiter, initSaturn, initUranus, initNeptune);
    }

    public static double run(int i) {
        return step(initialSystem(), energy(initialSystem()), i);
    }

    public static void main(String[] args) {
        long start = System.nanoTime();
        double init = run(0);
        double result = run(N);
        long end = System.nanoTime();
        long elapsed = (end - start) / 1000000;

        System.out.println("Time: " + elapsed + " ms");
        System.out.println("Initial: " + init);
        System.out.println("Result:  " + result);
    }

}

class Body {
    public double x, y, z, vx, vy, vz, m;

    public Body(double x, double y, double z, double vx, double vy, double vz, double m) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.vx = vx;
        this.vy = vy;
        this.vz = vz;
        this.m = m;
    }
}

class SolarSystem {
    public Body sun, jupiter, saturn, uranus, neptune;

    public SolarSystem(Body sun, Body jupiter, Body saturn, Body uranus, Body neptune) {
        this.sun = sun;
        this.jupiter = jupiter;
        this.saturn = saturn;
        this.uranus = uranus;
        this.neptune = neptune;
    }
}

