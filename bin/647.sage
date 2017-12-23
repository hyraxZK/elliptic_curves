# Tested using Sage 5.12
# You need to install the "database_pari" package:
# sage -i database_pari

#
# by Samuel Neves,
# this was cited in "A note on high-security general-purpose elliptic curves"
# by Aranha, Barreto, Pereira, and Ricardini https://eprint.iacr.org/2013/647/
#

def is_probable_prime(n):
    return n.is_prime(proof=False)

def montgomery_prime(m):
    p = 2 **m
    while True:
        p = previous_prime(p)
        if 5  == p % 8 :
            break
    return p

def montgomery_basepts(E, m, A, xin):
    p = montgomery_prime(m)
    F = GF(p)
    A = F(A)
    n = E.order()
    r = n // 8 
    assert(0  == n % 8  and is_probable_prime(r))
    # generator
    x = F(0 )
    while True:
        while True:
            x += 1 
            ok, y = is_square(x**3  + A*x**2  + x, root=True)
            if ok:
                break
        G = E([x,min(y,-y)])
        if (not 0  == 2 *G and not 0  == 4 *G and not 0  == 8 *G
           and not 0  == r*G and not 0  == 2 *r*G and not 0  == 4 *r*G
           and 0  == n*G):
            break
    # base point
    x = F(xin)
    while True:
        while True:
            x += 1 
            ok, y = is_square(x**3  + A*x**2  + x, root=True)
            if ok:
                break
        P = E([x,min(y, -y)])
        if not 0  == 8 *P and 0  == r*P:
            break
    return P, G

def montgomery_curve(m, A):
    try:
        p = montgomery_prime(m)
        delta = 2 **m - p
        if delta > m:
            return False

        F = GF(p)
        sgnA = '- %s' % (-A) if A < 0  else '+ %s' % (A)
        A = F(A)

        z = F(2 )
        if z.is_square():
            return False

        if is_square(A - 2 ) or is_square(A**2  - 4 ):
            return False

        # NB: now (A - 2)/(A + 2) is not a square either
        # check curve y^2 = x^3 + A*x^2 + x:
        E = EllipticCurve(F, [0 , A, 0 , 1 , 0 ])
        n = E.order()
        if(n % 8  != 0 ) or not is_probable_prime(n // 8 ):
            return False

        r = n // 8 
        if r < 2 **(m - 3 ):
            return False

        #  check twist v^2 = u^3 + A*z*u^2 + z^2*u:
        Et = EllipticCurve(F, [0 , A*z, 0 , z**2 , 0 ])
        nt = Et.order()
        if (nt % 4  != 0 ) or not is_probable_prime(nt // 4 ):
            return False

        rt = nt // 4 
        if rt < 2 **(m - 3 ):
            return False

        t = p + 1  - n
        if nt != p + 1  + t:
            return False

        r = n // 8 
        sec = round(log(sqrt(pi*r/4 ), 2 ), 1 )
        print "Good Elligator 2 curve: y^2 = x^3 + %s*x^2 + x over GF(2^%s - %s)" \
              " at sec level 2^%s with r = %s" % (sgnA,m,delta,sec,r)

        assert(is_probable_prime(r))
        # find base point and generattor
        P, G = montgomery_basepts(E, m, A, 3141592653 )
        print "Generator : %s" % (G)
        print "Base point 1: %s" % (P)
        P, _ = montgomery_basepts(E, m, A, 2718281828 )
        print "Base point 2: %s" % (P)

        return True
    except Exception as e:
        print e
        return False

def edwards_prime(m):
    p = 2 **m
    while True:
        p = previous_prime(p)
        if 3  == p % 4 :
            break
    return p


def edwards_basepts(E, m, d, yin):
    p = edwards_prime(m)
    F = GF(p)
    d = F(d)
    n = E.order()
    r = n // 4 
    assert(0  == n % 4  and is_probable_prime(r))

    # generator
    y = F(0 )
    while True:
        while True:
            y += 1 
            U = (1  - d)*(1  - y)/(1  + y)
            ok, V = is_square(U**3  + (2 *d + 2 )*U**2  + (1  - d)**2 *U, root=True)
            if ok:
                break
        G = E([U,V])
        if (not 0  == 2 *G and not 0  == 4 *G and not 0  == r*G
            and not 0  == 2 *r*G and 0  == n*G):
            break
    x = 2 *U/V
    assert(x**2  + y**2  == 1  + d*x**2 *y**2 )
    G = (min(x,-x), y)

    # base point
    y = F(yin)
    while True:
        while True:
            y += 1 
            U = (1  - d)*(1  - y)/(1  + y)
            ok, V = is_square(U**3  + (2 *d + 2 )*U**2  + (1  - d)**2 *U, root=True)
            if ok:
                break
        P = E([U,V])
        if not 0  == 4 *P and 0  == r * P:
            break
    x = 2 *U/V
    assert(x**2  + y**2  == 1  + d*x**2 *y**2 )
    P = (min(x,-x), y)

    return P, G

def edwards_curve(m, d):
    try:
        p = edwards_prime(m)
        delta = 2 **m - p
        m0 = 2 *m if m == 168  else m # Telex exception
        if delta > m0:
            return False

        F = GF(p)
        sgnd = '- %s' % (-d) if d < 0  else '+ %s' % (d)
        d = F(d)
        if is_square(d) or is_square(1  - d) or not is_square(-d):
            return False

        u = sqrt(-d)
        if not is_square(2 *(u - 1 )/(u + 1 )):
            return False

        # check curve x^2 + y^2 = 1 + dx^2y^2,
        # or equivalently y^2 = x^3 + (2d + 2) x^2 + (1 - d)^2 x:
        E = EllipticCurve(F, [0 , (2 *d + 2 ), 0 , (1  - d)**2 , 0 ])
        n = E.order()
        if n % 4  != 0  or not is_probable_prime(n // 4 ):
            return False

        r = n // 4 
        if r < 2 **(m - 3 ):
            return False

        # check twist x^2 + y^2 = 1 + (1/d)x^2y^2,
        # or equivalently v^2 = u^3 + 2(1 + d)/(1 - d)u^2 + u:
        Et = EllipticCurve(F, [0 , 2 *(1  + d)/(1  - d), 0 , 1 , 0 ])
        nt = Et.order()

        if nt % 4  != 0  or not is_probable_prime(nt // 4 ):
            return False

        rt = nt // 4 
        if rt < 2 **(m - 3 ):
            return False

        t = p + 1  - n
        if nt != p + 1  + t:
            return False

        r = n // 4 
        sec = round(log(sqrt(pi*r/4 ), 2 ), 1 )
        print "Good Elligator 1 curve: x^2 + y^2 = 1 %s*x^2*y^2 over GF(2^%s - %s)" \
              " at sec level 2^%s with r = %s" % (sgnd,m,delta,sec,r)
        assert(is_probable_prime(r))
        P, G = edwards_basepts(E, m, d, 3141592653 )
        print "Generator : (%s : %s : 1)" % (G[0 ],G[1 ])
        print "Base point 1: (%s : %s : 1)" % (P[0 ],P[1 ])
        P, _ = edwards_basepts(E, m, d, 2718281828 )
        print "Base point 2: (%s : %s : 1)" % (P[0 ],P[1 ])
        return True
    except Exception as e:
        print e
        return False

type1_curves = [(157, -42000), (168, -715), (190, -15584), (222, 160102), (251, -1174), (382, -67254), (521, -376014)]
type2_curves = [(159, 197782), (191, -281742), (221, 117050), (255, 486662), (383, 2065150), (511, 530438)]

print "================"
for m, A in type2_curves:
    if not montgomery_curve(m, A):
        print "LOGIC ERROR!"
    print "================"

print "================"
for m, d in type1_curves:
    if not edwards_curve(m, d):
        print "LOGIC ERROR!"
    print "================"

