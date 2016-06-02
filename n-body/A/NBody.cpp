#include <cstdio>
#include <chrono>
#include <tuple>
#include <cmath>

// n-body, from the Computer Language Benchmarks Game
// http://benchmarksgame.alioth.debian.org/u64q/nbody-description.html#nbody

// This implementation is a close translation of the Flix program, which was loosely based on:
// http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=java&id=2

const int N = 100000;

const double pi = 3.141592653589793;
const double solarMass = 4.0 * (pi * pi);
const double daysPerYear = 365.24;

double distance(double dx, double dy, double dz) {
    return pow((dx * dx) + (dy * dy) + (dz * dz), 0.5);
}

struct Body {
    const double x, y, z, vx, vy, vz, m;

    Body(double x, double y, double z, double vx, double vy, double vz, double m) :
      x(x), y(y), z(z), vx(vx), vy(vy), vz(vz), m(m) {}
};

struct SolarSystem {
    const Body sun, jupiter, saturn, uranus, neptune;

    SolarSystem(const Body& sun, const Body& jupiter, const Body& saturn, const Body& uranus, const Body& neptune) :
      sun(sun), jupiter(jupiter), saturn(saturn), uranus(uranus), neptune(neptune) {}
};

const Body offsetMomentum(const Body& b, double px, double py, double pz) {
    return Body(b.x, b.y, b.z, -px / solarMass, -py / solarMass, -pz / solarMass, b.m);
}

double getSpeedSq(const Body& b) {
    return (b.vx * b.vx) + (b.vy * b.vy) + (b.vz * b.vz);
}

double getEnergy(const Body& b) {
    return 0.5 * b.m * getSpeedSq(b);
}

const Body moveBody(const Body& b, double dt) {
    return Body(b.x + (dt * b.vx), b.y + (dt * b.vy), b.z + (dt * b.vz), b.vx, b.vy, b.vz, b.m);
}

const Body advanceBody(const Body& b, double dx, double dy, double dz, double delta) {
    return Body(b.x, b.y, b.z, b.vx + (dx * delta), b.vy + (dy * delta), b.vz + (dz * delta), b.m);
}

const std::tuple<Body, Body> advanceHelper(const Body& b1, const Body& b2, double dt) {
    const double dx = b1.x - b2.x;
    const double dy = b1.y - b2.y;
    const double dz = b1.z - b2.z;
    const double d = distance(dx, dy, dz);
    const double mag = dt / (d * d * d);
    const Body newB1 = advanceBody(b1, dx, dy, dz, -b2.m * mag);
    const Body newB2 = advanceBody(b2, dx, dy, dz, b1.m * mag);
    return {newB1, newB2};
}

const SolarSystem advance(const SolarSystem& s, double dt) {
    const auto r1 = advanceHelper(s.sun, s.jupiter, dt);
    const Body sun1 = std::get<0>(r1);
    const Body jupiter1 = std::get<1>(r1);
    const auto r2 = advanceHelper(sun1, s.saturn, dt);
    const Body sun2 = std::get<0>(r2);
    const Body saturn1 = std::get<1>(r2);
    const auto r3 = advanceHelper(sun2, s.uranus, dt);
    const Body sun3 = std::get<0>(r3);
    const Body uranus1 = std::get<1>(r3);
    const auto r4 = advanceHelper(sun3, s.neptune, dt);
    const Body sun4 = std::get<0>(r4);
    const Body neptune1 = std::get<1>(r4);
    const auto r5 = advanceHelper(jupiter1, saturn1, dt);
    const Body jupiter2 = std::get<0>(r5);
    const Body saturn2 = std::get<1>(r5);
    const auto r6 = advanceHelper(jupiter2, uranus1, dt);
    const Body jupiter3 = std::get<0>(r6);
    const Body uranus2 = std::get<1>(r6);
    const auto r7 = advanceHelper(jupiter3, neptune1, dt);
    const Body jupiter4 = std::get<0>(r7);
    const Body neptune2 = std::get<1>(r7);
    const auto r8 = advanceHelper(saturn2, uranus2, dt);
    const Body saturn3 = std::get<0>(r8);
    const Body uranus3 = std::get<1>(r8);
    const auto r9 = advanceHelper(saturn3, neptune2, dt);
    const Body saturn4 = std::get<0>(r9);
    const Body neptune3 = std::get<1>(r9);
    const auto r10 = advanceHelper(uranus3, neptune3, dt);
    const Body uranus4 = std::get<0>(r10);
    const Body neptune4 = std::get<1>(r10);
    return SolarSystem(moveBody(sun4, dt), moveBody(jupiter4, dt), moveBody(saturn4, dt), moveBody(uranus4, dt), moveBody(neptune4, dt));
}

double energyHelper(const Body& b1, const Body& b2) {
    const double dx = b1.x - b2.x;
    const double dy = b1.y - b2.y;
    const double dz = b1.z - b2.z;
    return (b1.m * b2.m) / distance(dx, dy, dz);
}

double energy(const SolarSystem& s) {
    const Body sun = s.sun;
    const Body jupiter = s.jupiter;
    const Body saturn = s.saturn;
    const Body uranus = s.uranus;
    const Body neptune = s.neptune;
    const double posE = getEnergy(sun) + getEnergy(jupiter) + getEnergy(saturn) + getEnergy(uranus) + getEnergy(neptune);
    const double negE = energyHelper(sun, jupiter) + energyHelper(sun, saturn) + energyHelper(sun, uranus) + energyHelper(sun, neptune) +
                        energyHelper(jupiter, saturn) + energyHelper(jupiter, uranus) + energyHelper(jupiter, neptune) +
                        energyHelper(saturn, uranus) + energyHelper(saturn, neptune) +
                        energyHelper(uranus, neptune);
    return posE - negE;
}

double step(const SolarSystem& s, double e, int i) {
    if (i == 0) {
        return e;
    } else {
        const SolarSystem s1 = advance(s, 0.01);
        return step(s1, energy(s1), i - 1);
    }
}

const Body initJupiter() {
    return Body(
        4.84143144246472090,
        -1.16032004402742839,
        -0.103622044471123109,
        0.00166007664274403694 * daysPerYear,
        0.00769901118419740425 * daysPerYear,
        -0.0000690460016972063023 * daysPerYear,
        0.000954791938424326609 * solarMass);
}
const Body initSaturn() {
    return Body(
        8.34336671824457987,
        4.12479856412430479,
        -0.403523417114321381,
        -0.00276742510726862411 * daysPerYear,
        0.00499852801234917238 * daysPerYear,
        0.0000230417297573763929 * daysPerYear,
        0.000285885980666130812 * solarMass);
}
const Body initUranus() {
    return Body(
        12.8943695621391310,
        -15.1111514016986312,
        -0.223307578892655734,
        0.00296460137564761618 * daysPerYear,
        0.00237847173959480950 * daysPerYear,
        -0.0000296589568540237556 * daysPerYear,
        0.0000436624404335156298 * solarMass);
}
const Body initNeptune() {
    return Body(
        15.3796971148509165,
        -25.9193146099879641,
        0.179258772950371181,
        0.00268067772490389322 * daysPerYear,
        0.00162824170038242295 * daysPerYear,
        -0.0000951592254519715870 * daysPerYear,
        0.0000515138902046611451 * solarMass);
}
const Body initSun() {
    return Body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, solarMass);
}

const SolarSystem initialSystem() {
    const Body sun = initSun();
    const Body jupiter = initJupiter();
    const Body saturn = initSaturn();
    const Body uranus = initUranus();
    const Body neptune = initNeptune();
    const double px = (sun.vx * sun.m) +
                      (jupiter.vx * jupiter.m) +
                      (saturn.vx * saturn.m) +
                      (uranus.vx * uranus.m) +
                      (neptune.vx * neptune.m);
    const double py = (sun.vy * sun.m) +
                      (jupiter.vy * jupiter.m) +
                      (saturn.vy * saturn.m) +
                      (uranus.vy * uranus.m) +
                      (neptune.vy * neptune.m);
    const double pz = (sun.vz * sun.m) +
                      (jupiter.vz * jupiter.m) +
                      (saturn.vz * saturn.m) +
                      (uranus.vz * uranus.m) +
                      (neptune.vz * neptune.m);
    const Body sun1 = offsetMomentum(sun, px, py, pz);
    return SolarSystem(sun1, jupiter, saturn, uranus, neptune);
}

double run(int i) {
    return step(initialSystem(), energy(initialSystem()), i);
}

int main(int, char**) {
    auto start = std::chrono::high_resolution_clock::now();
    auto init = run(0);
    auto result = run(N);
    auto end = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() / 1000000;

    printf("Time: %ld ms\n", elapsed);
    printf("Initial: %.16f\n", init);
    printf("Result:  %.16f\n", result);
}

