########## this contains functions to compute effective dynamics of LQC ##########
import numpy as np
from scipy.integrate import solve_ivp
import math

# constants
G = 1.
hbar = 1.
kappa = 8.*np.pi*G
gamma = 0.2375
Delta = 4.*np.sqrt(3.)*np.pi*G*hbar*gamma
rhoc = 3./(kappa*gamma**2*Delta)
# observable window numbers
Nafter = 70 # number of efolds since inflation ended until today
kobs_min = 1e-4 # min observed wavenumber today in Mpc-1
kobs_max = 0.5 # max observed wavenumber today in Mpc-1
conversion = 1./(3.086e22/np.sqrt(2.6121e-70)) # Mpc-1 in planck units

### functions

# potential V(phi) options are "Star", "Quad" and "Alpha"
def V(phi,arg):
    pot = arg[0]
    if pot == "Star":
        V0 = arg[1]
        return V0*(1.-np.exp(-np.sqrt(2.*kappa/3.)*phi))**2.
    elif pot == "Quad":
        V0 = arg[1]
        return 0.5*V0*phi**2
    elif pot == "Alpha":
        V0,alpha = arg[1:]
        return V0*(1.-np.exp(-np.sqrt(2.*kappa/(3.*alpha))*phi))**2.

# dV(phi)/dphi
def dVdphi(phi,arg):
    pot = arg[0]
    if pot == "Star":
        V0 = arg[1]
        return 2.*np.sqrt(2.*kappa/3.)*V0*(1.-np.exp(-np.sqrt(2.*kappa/3.)*phi))*np.exp(-np.sqrt(2.*kappa/3.)*phi)
    elif pot == "Quad":
        V0 = arg[1]
        return V0*phi
    elif pot == "Alpha":
        V0,alpha = arg[1:]
        return 2.*np.sqrt(2.*kappa/(3.*alpha))*V0*(1.-np.exp(-np.sqrt(2.*kappa/(3.*alpha))*phi))*np.exp(-np.sqrt(2.*kappa/(3.*alpha))*phi)

# d^2V(phi)/dphi^2
def d2Vdphi2(phi,arg):
    pot = arg[0]
    if pot == "Star":
        V0 = arg[1]
        return 4.*kappa/3.*V0*(2.*np.exp(-np.sqrt(2.*kappa/3.)*phi)-1)*np.exp(-np.sqrt(2.*kappa/3.)*phi)
    elif pot == "Quad":
        V0 = arg[1]
        return V0
    elif pot == "Alpha":
        V0,alpha = arg[1:]
        return 4.*kappa/(3.*alpha)*V0*(2.*np.exp(-np.sqrt(2.*kappa/(3.*alpha))*phi)-1)*np.exp(-np.sqrt(2.*kappa/(3.*alpha))*phi)

# energy density
def rho(phi,dphi,arg):
    phi = np.asarray(phi) # convert to arrays if it isn't
    dphi = np.asarray(dphi)
    return dphi**2/2. + V(phi, arg)

# pressure
def P(phi,dphi,arg):
    phi = np.asarray(phi) # convert to arrays if it isn't
    dphi = np.asarray(dphi)
    return dphi**2/2. - V(phi, arg)

#Ricci scalar
def Ricci(phi,dphi,arg):
    return kappa*rho(phi,dphi,arg)*(1+2*rho(phi,dphi,arg)/rhoc)-3*kappa*P(phi,dphi,arg)*(1-2*rho(phi,dphi,arg)/rhoc)

#curvature radius
def rc(phi,dphi,arg):
    return np.sqrt(abs(6/Ricci(phi,dphi,arg)))

#z''/z through direct quantities
def zppz(a,H,phi,dphi,arg):
    phi_p = a*dphi # phi'
    rho = 3.*H**2/kappa
    term1 = -kappa*phi_p**2/6.*(1.-22.*rho/rhoc-18.*rho**2/rhoc**2/(1.-rho/rhoc))
    term2 = -16.*kappa/3.*a**2*V(phi,arg)*(1.-rho/rhoc+9./8.*rho**2/rhoc**2/(1-rho/rhoc))
    term3 = -a**2*d2Vdphi2(phi,arg)-6.*a*H*phi_p/rho*dVdphi(phi,arg)*(1.-rho/rhoc/(1.-rho/rhoc))
    term4 = 6.*kappa*a**2*V(phi,arg)**2/rho*(1.-rho/rhoc+rho**2/rhoc**2/(1.-rho/rhoc))
    return term1 + term2 + term3 + term4
    
#z''/z of hybridLQC
def zppz_hLQC(a,H,phi,dphi,arg):
    U = a**2.*(d2Vdphi2(phi,arg)+6.*kappa*V(phi,arg)+6.*H*dphi*dVdphi(phi,arg)/rho(phi,dphi,arg)-6.*kappa*V(phi,arg)**2./rho(phi,dphi,arg))
    return kappa/6.*a**2.*(rho(phi,dphi,arg)-3.*P(phi,dphi,arg))-U

#z''/z of dressed metric
def zppz_dressed(a,H,phi,dphi,arg):
    U = a**2.*(d2Vdphi2(phi,arg)+6.*kappa*V(phi,arg)-2.*np.sqrt(3.*kappa)*dphi*dVdphi(phi,arg)/np.sqrt(rho(phi,dphi,arg))-6.*kappa*V(phi,arg)**2./rho(phi,dphi,arg))
    return kappa/6.*a**2.*rho(phi,dphi,arg)*(1.+2.*rho(phi,dphi,arg)/rhoc)-kappa/2.*a**2*P(phi,dphi,arg)*(1.-2.*rho(phi,dphi,arg)/rhoc)-U


#--- functions for numerical integration of effective dynamics ---#

# eom for v (expanding branch -> positive sqrt)
def dvdt(v,phi,dphi,arg):
    rho_val = rho(phi, dphi, arg)
    factor = 1.-rho_val/rhoc
    return np.sqrt(3.*kappa*v**2*rho_val*np.abs(factor)) #abs is just to ensure "factor" doesn't go negative due to numerical errors when very close to zero. Can be tested e.g. with prints, tested for ranges of params used
 
# eom for phi
def dphidt(v,piphi):
    return 4./(kappa*hbar*gamma*np.sqrt(Delta))*piphi/np.abs(v)

# eom for pi_phi
def dpiphidt(v,phi,arg):
    return -kappa*hbar*gamma*np.sqrt(Delta)/4.*np.abs(v)*dVdphi(phi,arg)

# eom for T
def dTdt(v):
    return kappa*hbar*gamma*np.sqrt(Delta)*np.abs(v)/4

# set of background eoms, integrating ln(v) instead of v for numerical efficiency
def bckgEOMs(t,y,arg):
    lnv,phi,piphi,T = y
    v = np.exp(lnv)
    dphi = dphidt(v,piphi)
    dpiphi = dpiphidt(v,phi,arg)
    dT = dTdt(v)
    dlnv = 3.*Heff(v,phi,piphi,arg)
    if t<=0: dlnv = -dlnv
    return[dlnv,dphi,dpiphi,dT]

def Heff(v,phi,piphi,arg):
    dphi = dphidt(v,piphi)
    factor = 1.-rho(phi,dphi,arg)/rhoc
    return np.sqrt(kappa/3.*rho(phi,dphi,arg)*np.abs(factor))

#pi_phi from constraint knowing v, phi, (sin(b))^2 and the sign we want for pi_phi (s)
def piphiConstr(v,phi,sin2b,s,arg):
    return s*np.abs(v)*np.sqrt(3.*kappa*hbar**2/8.*sin2b-kappa**2*hbar**2*gamma**2*Delta/8.*V(phi,arg))

# kinetic energy at the bounce given phiB
def rhok_phiB(phiB,arg):
    piphiB = piphiConstr(1.,phiB,1.,1.,arg)
    return dphidt(1.,piphiB)**2./2.


#------- functions to run integration -------#
def effdynamics(v0,phi0,T0,spiphi,ts,arg,method="RK45"):
    sin2b0 = 1. # bounce
    piphi0 = piphiConstr(v0,phi0,sin2b0,spiphi,arg) # spiphi defines sign
    ics = [np.log(v0),phi0,piphi0,T0]
    ti = ts[0]
    tf = ts[-1]
    # numerical integration
    sol = solve_ivp(bckgEOMs,[ti,tf],ics,args=(arg,),method=method,t_eval=ts,rtol=1e-3,atol=1e-6)
    return sol

def extract_eff_info(sol,arg):
    #--- extract vars from sols ---#
    lnvt, phit, piphit, Tt = sol.y
    # convert back to volume
    vt = np.exp(lnvt)
    at = vt**(1./3.)
    #--- other derived quantities ---#
    ## hubble and aH
    Ht = Heff(vt,phit,piphit,arg)
    aHt = at*Ht
    ## identifying inflation
    # find index of beginning of inflation:
    iinf = np.argmin(aHt[1:])+1
    # find index of end of inflation:
    iend = np.argmax(aHt[iinf:])+iinf
    ## ln(a)
    lna = lnvt/3.0
    ## z''/z
    phidot = dphidt(vt,piphit)
    d2z_z = zppz(at,Ht,phit,phidot,arg)
    d2z_z_h = zppz_hLQC(at,Ht,phit,phidot,arg)
    d2z_z_d = zppz_dressed(at,Ht,phit,phidot,arg)
    ### observable window
    NT = lna[iend]+Nafter
    kmin = kobs_min*conversion*np.exp(NT)
    kmax = kobs_max*conversion*np.exp(NT)
    ### curvature radius
    rct =rc(phit,phidot,arg) # curvature radius
    com_rct = rct/vt**(1./3.) # comoving curv radius (units of 1/k)
    return(Ht,aHt,iinf,iend,lna,d2z_z_h,d2z_z_d,d2z_z,com_rct,NT,kmin,kmax)

