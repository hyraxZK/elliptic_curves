
# Tested using Sage 5.12
# You need to install the "database_pari" package:
# sage -i database_pari

#
# Adapted from 647.sage by Samuel Neves,
# which was reffed in "A note on high-security general-purpose elliptic curves"
# by Aranha, Barreto, Pereira, and Ricardini https://eprint.iacr.org/2013/647/
#

def is_probable_prime(n):
    return n.is_prime(proof=False)

def montgomery_prime(m):
    p = 2^m
    while True:
        p = previous_prime(p)
        if 5 == p % 8:
            break
    return p

def montgomery_basepts(E, m, A, xin):
    p = montgomery_prime(m)
    F = GF(p)
    A = F(A)
    n = E.order()
    r = n // 8
    assert(0 == n % 8 and is_probable_prime(r))
    # generator
    x = F(0)
    while True:
        while True:
            x += 1
            ok, y = is_square(x^3 + A*x^2 + x, root=True)
            if ok:
                break
        G = E([x,min(y,-y)])
        if (not 0 == 2*G and not 0 == 4*G and not 0 == 8*G
           and not 0 == r*G and not 0 == 2*r*G and not 0 == 4*r*G
           and 0 == n*G):
            break
    # base point
    x = F(xin)
    while True:
        while True:
            x += 1
            ok, y = is_square(x^3 + A*x^2 + x, root=True)
            if ok:
                break
        P = E([x,min(y, -y)])
        if not 0 == 8*P and 0 == r*P:
            break
    return P, G

def montgomery_curve(m, A):
    try:
        p = montgomery_prime(m)
        delta = 2^m - p
        if delta > m:
            return False

        F = GF(p)
        sgnA = '- %s' % (-A) if A < 0 else '+ %s' % (A)
        A = F(A)

        z = F(2)
        if z.is_square():
            return False

        if is_square(A - 2) or is_square(A^2 - 4):
            return False

        # NB: now (A - 2)/(A + 2) is not a square either
        # check curve y^2 = x^3 + A*x^2 + x:
        E = EllipticCurve(F, [0, A, 0, 1, 0])
        n = E.order()
        if(n % 8 != 0) or not is_probable_prime(n // 8):
            return False

        r = n // 8
        if r < 2^(m - 3):
            return False

        #  check twist v^2 = u^3 + A*z*u^2 + z^2*u:
        Et = EllipticCurve(F, [0, A*z, 0, z^2, 0])
        nt = Et.order()
        if (nt % 4 != 0) or not is_probable_prime(nt // 4):
            return False

        rt = nt // 4
        if rt < 2^(m - 3):
            return False

        t = p + 1 - n
        if nt != p + 1 + t:
            return False

        r = n // 8
        sec = round(log(sqrt(pi*r/4), 2), 1)
        #print "Good Elligator 2 curve: y^2 = x^3 + %s*x^2 + x over GF(2^%s - %s)" \
        #      " at sec level 2^%s with r = %s" % (sgnA,m,delta,sec,r)

        assert(is_probable_prime(r))
        # find base point and generattor
        P, G = montgomery_basepts(E, m, A, 3141592653)
        #print "Generator : %s" % (G)
        #print "Base point 1: %s" % (P)
        P2, _ = montgomery_basepts(E, m, A, 2718281828)
        #print "Base point 2: %s" % (P2)

        # need at least one spare bit for point compression, which this guarantees
        nBits = 4 * (1 + m // 4)

        ### Conversions below assume that this is a curve with B=1
        ## convert Montgomery to Weierstrass coefficients
        a = F((3 - A**2)/3)
        b = F((2*A**3-9*A)/27)
        ## convert base points to Weierstrass coordinates
        # y' = y
        P2y = P2[1]
        P1y = P[1]
        # x' = x + A/3
        P2x = F(P2[0] + A/3)
        P1x = F(P[0] + A/3)

        print "%d\n%x\n%x\n%x\n%x\n%x\n%x\n%x\n%x" % (nBits, p, a, b, r, P2x, P2y, P1x, P1y)

        return True
    except Exception as e:
        print e
        return False

type2_curves = [(159, 197782), (191, -281742), (221, 117050), (255, 486662)]

for m, A in type2_curves:
    print "## m%d" % m
    if not montgomery_curve(m, A):
        print "LOGIC ERROR!"
