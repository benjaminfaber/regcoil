import numpy as np
import os
import re
from regcoilScan import readVariable, namelistLineContains
from shutil import copyfile
import subprocess
import sys
from scipy.io import netcdf

class coilFourier:

  def __init__(self,nmax,mmax,regcoil_input_file):
    self.regcoil_input_file = regcoil_input_file
    nmax_sensitivity = readVariable("nmax_sensitivity","int",regcoil_input_file,required=True)
    mmax_sensitivity = readVariable("mmax_sensitivity","int",regcoil_input_file,required=True)
    geometry_option_coil = readVariable("geometry_option_coil","int",regcoil_input_file,required=True)
    geometry_option_plasma = readVariable("geometry_option_plasma","int",regcoil_input_file,required=True)
    general_option = readVariable("general_option","int",regcoil_input_file,required=True)
    self.general_option = general_option
    if (general_option > 3):
      current_density_target = readVariable("current_density_target","float",regcoil_input_file,required=False)
      self.current_density_target = current_density_target
      self.current_density_target_init = current_density_target
      target_option = readVariable("target_option","int",regcoil_input_file,required=True)
      self.target_option = target_option
    spectral_norm_p = readVariable("spectral_norm_p","float",regcoil_input_file,required=False)
    spectral_norm_q = readVariable("spectral_norm_q","float",regcoil_input_file,required=False)
    self.spectral_norm_p = spectral_norm_p
    self.spectral_norm_q = spectral_norm_q
    if (self.spectral_norm_p==None):
      self.spectral_norm_p = 2
    if (self.spectral_norm_q==None):
      self.spectral_norm_q = 2

    alpha1 = readVariable("alpha1","float",regcoil_input_file,required=False)
    alpha2 = readVariable("alpha2","float",regcoil_input_file,required=False)
    alpha3 = readVariable("alpha3","float",regcoil_input_file,required=False)
    alpha4 = readVariable("alpha4","float",regcoil_input_file,required=False)
    alpha5 = readVariable("alpha5","float",regcoil_input_file,required=False)

    scaleFactor = readVariable("scaleFactor","float",regcoil_input_file,required=False)
    
    self.alpha1 = alpha1
    self.alpha2 = alpha2
    self.alpha3 = alpha3
    self.alpha4 = alpha4
    self.alpha5 = alpha5
    self.scaleFactor = scaleFactor
    if (alpha1 == None):
      self.alpha1 = 0
    if (alpha2 == None):
      self.alpha2 = 0
    if (alpha3 == None):
      self.alpha3 = 0
    if (alpha4 == None):
      self.alpha4 = 0
    if (alpha5 == None):
      self.alpha5 = 0
    if (scaleFactor == None):
      self.scaleFactor = 1.0
    # Check parameters
    if (geometry_option_plasma < 2 or geometry_option_plasma > 4):
      print "Error! This script is only compatible with geometry_option_plasma=(3,4,5) at the moment."
      sys.exit(0)
    if (geometry_option_coil != 3):
      print "Error! This script is only compatible with geometry_option_coil=3 at the moment."
      sys.exit(0)

    self.nmax_sensitivity = nmax_sensitivity
    self.mmax_sensitivity = mmax_sensitivity
    self.nmax = nmax
    self.mmax = mmax
    # Number of modes - does not include factor of 2 from (rmnc,zmns) - not # of Fourier coefficients
    nmodes_sensitivity = (nmax_sensitivity+1) + (2*nmax_sensitivity+1)*mmax_sensitivity
    self.dspectral_normdomegas = np.zeros(2*nmodes_sensitivity)
    self.spectral_norm = 0
    nmodes = (nmax+1) + (2*nmax+1)*mmax
    self.nmodes = nmodes
    self.nmodes_sensitivity = nmodes_sensitivity
    self.rmncs = np.zeros(nmodes)
    self.zmnss = np.zeros(nmodes)
    self.rmnss = np.zeros(nmodes)
    self.zmncs = np.zeros(nmodes)
    self.xn = np.zeros(nmodes)
    self.xm = np.zeros(nmodes)
    self.xn_sensitivity = np.zeros(nmodes_sensitivity)
    self.xm_sensitivity = np.zeros(nmodes_sensitivity)
    self.omegas = np.zeros(2*nmodes)
    self.omegas_sensitivity = np.zeros(2*nmodes_sensitivity)
    self.objective_function = 0
    self.dobjective_functiondomegas_sensitivity = np.zeros(2*nmodes_sensitivity)
    self.evaluated = False # has function been evaluated at current omegas_sensitivity?
    self.feval = 0 # Number of function evaluations
    self.chi2B = 0
    self.chi2K = 0
    self.RMSK = 0
    self.area_coil = 0
    self.dchi2Bdomega = 0
    self.dchi2Kdomega = 0
    self.darea_coildomega = 0
    self.coil_volume = 0
    self.dcoil_volumedomega = 0
    self.dcoil_plasma_dist_mindomega = 0
    self.dcoil_plasma_dist_maxdomega = 0
    self.coil_plasma_dist_min_lse = 0
    self.coil_plasma_dist_max_lse = 0
    self.increased_target_current = False
    self.decreased_target_current = False
    self.current_factor = 0.1
    # Initialize m = 0 modes
    imode = 0
    for ni in range(0,nmax+1):
      self.xn[imode] = ni
      self.xm[imode] = 0
      imode = imode + 1
    # Initialize m > 0 modes
    for mi in range(1,mmax+1):
      for ni in range(-nmax,nmax+1):
        self.xn[imode] = ni
        self.xm[imode] = mi
        imode = imode + 1
    imode = 0
    for ni in range(0,nmax_sensitivity+1):
      self.xn_sensitivity[imode] = ni
      self.xm_sensitivity[imode] = 0
      imode = imode + 1
    for mi in range(1,mmax_sensitivity+1):
      for ni in range(-nmax_sensitivity,nmax_sensitivity+1):
        self.xn_sensitivity[imode] = ni
        self.xm_sensitivity[imode] = mi
        imode = imode + 1

  def set_omegas_sensitivity(self,new_omegas_sensitivity):
    self.omegas_sensitivity = new_omegas_sensitivity
    for imn in range(0, self.nmodes_sensitivity):
      for jmn in range(0, self.nmodes):
        if (self.xn[jmn] == self.xn_sensitivity[imn]):
          if (self.xm[jmn] == self.xm_sensitivity[imn]):
            self.rmncs[jmn] = self.omegas_sensitivity[2*imn]
            self.zmnss[jmn] = self.omegas_sensitivity[2*imn+1]
            self.omegas[2*jmn] = self.omegas_sensitivity[2*imn]
            self.omegas[2*jmn+1] = self.omegas_sensitivity[2*imn+1]
  # Function has not been evaluated at new omegas
    self.evaluated = False

  def set_dchi2Bdomega(self,dchi2Bdomega):
    self.dchi2Bdomega = dchi2Bdomega
  
  def set_dchi2Kdomega(self,dchi2Kdomega):
    self.dchi2Kdomega = dchi2Kdomega
  
  def set_darea_coildomega(self,darea_coildomega):
    self.darea_coildomega = darea_coildomega

  def set_dcoil_volumedomega(self,dcoil_volumedomega):
    self.dcoil_volumedomega = dcoil_volumedomega

  def set_dcoil_plasma_dist_mindomega(self,dcoil_plasma_dist_mindomega):
    self.dcoil_plasma_dist_mindomega = dcoil_plasma_dist_mindomega
  
  def set_dcoil_plasma_dist_maxdomega(self,dcoil_plasma_dist_maxdomega):
    self.dcoil_plasma_dist_maxdomega = dcoil_plasma_dist_maxdomega

  def set_dobjective_functiondomegas(self,dobjective_functiondomegas_sensitivity):
    self.dobjective_functiondomegas_sensitivity = dobjective_functiondomegas_sensitivity
  
  def increment_feval(self):
    self.feval = self.feval + 1
  
  def compute_spectral_norm(self):
    self.spectral_norm = 0
    dspectral_normdomegas = np.zeros(2*self.nmodes_sensitivity)
    for imode in range(0,self.nmodes_sensitivity):
      self.spectral_norm = self.spectral_norm + self.xm_sensitivity[imode]**(self.spectral_norm_p)*(self.omegas_sensitivity[2*imode]**2 + self.omegas_sensitivity[2*imode+1]**2)
      dspectral_normdomegas[2*imode] = self.xm_sensitivity[imode]**(self.spectral_norm_p)*2*self.omegas_sensitivity[2*imode]
      dspectral_normdomegas[2*imode+1] = self.xm_sensitivity[imode]**(self.spectral_norm_p)*2*self.omegas_sensitivity[2*imode+1]
    self.set_dspectral_normdomegas(dspectral_normdomegas)
  
  def set_Fourier_from_nescin(self,nescin_file):
    file = open(nescin_file, "r")
    imode = 0
    inCurrentGeometry = 0
    for line in file:
      if (inCurrentGeometry):
        list = line.split()
        this_m = int(list[0])
        this_n = int(list[1])
        rmnc = float(list[2])
        zmns = float(list[3])
        for imn in range(0,self.nmodes):
          if (self.xm[imn]==this_m and self.xn[imn]==this_n):
            self.rmncs[imn] = rmnc
            self.zmnss[imn] = zmns
            self.omegas[2*imn] = rmnc
            self.omegas[2*imn+1] = zmns
        for imn in range(0,self.nmodes_sensitivity):
          if (self.xn_sensitivity[imn]==this_n and self.xm_sensitivity[imn]==this_m):
            self.omegas_sensitivity[2*imn] = rmnc
            self.omegas_sensitivity[2*imn+1] = zmns
      if re.match("------ Current Surface",line):
        inCurrentGeometry = 1
        next(file)
        next(file)
        next(file)
        next(file)
    file.close()

  def set_dspectral_normdomegas(self,new_dspectral_normdomegas):
    self.dspectral_normdomegas = new_dspectral_normdomegas
  
  def evaluateObjectiveFunction(self):
    self.compute_spectral_norm()
    RMSK = (self.chi2K/self.area_coil)**(0.5)
    print "RMSK: " + str(RMSK)
    print "chi2B: " + str(self.chi2B)
    print "coil_volume: " + str(self.coil_volume)
    print "coil_plasma_dist_min: " + str(self.coil_plasma_dist_min_lse)
    print "spectral_norm: " + str(self.spectral_norm)
    print "norm(dchi2Kdomega): " + str(np.linalg.norm(self.dchi2Kdomega,2))
    print "norm(darea_coildomega): " + str(np.linalg.norm(self.darea_coildomega,2))
    dRMSKdomega = (0.5/RMSK)*(self.dchi2Kdomega/self.area_coil - self.chi2K*self.darea_coildomega/(self.area_coil**2))
    print "norm(dRMSKdomega): " + str(np.linalg.norm(dRMSKdomega,2))
    print "norm(dchi2Bdomega): " + str(np.linalg.norm(self.dchi2Bdomega,2))
    print "norm(dcoil_volumedomega): " + str(np.linalg.norm(self.dcoil_volumedomega,2))
    print "norm(dcoil_plasma_dist_mindomega): " + str(np.linalg.norm(self.dcoil_plasma_dist_mindomega,2))
    print "norm(dspectral_normdomegas): " + str(np.linalg.norm(self.dspectral_normdomegas,2))
    
    self.objective_function = self.scaleFactor*(self.alpha4*self.chi2B - self.alpha3*self.coil_plasma_dist_min_lse - self.alpha1*self.coil_volume**(1.0/3.0) + self.alpha2*self.spectral_norm + self.alpha5*self.RMSK)
    self.set_dobjective_functiondomegas(self.scaleFactor*(self.alpha4*self.dchi2Bdomega - self.alpha3*self.dcoil_plasma_dist_mindomega - self.alpha1*(1.0/3.0)*(self.coil_volume**(-2.0/3.0))*self.dcoil_volumedomega + self.alpha2*self.dspectral_normdomegas + self.alpha5*dRMSKdomega))

  # This is a script to be called within a nonlinear optimization routine in order to evaluate
  # chi2 and its gradient with respect to the Fourier coefficients
  def evaluateRegcoil(self,omegas_sensitivity_new,current_density_target=0):
    
    self.set_omegas_sensitivity(omegas_sensitivity_new.copy())
    
    regcoil_input_file = self.regcoil_input_file
    
    wout_filename = readVariable("wout_filename","string",regcoil_input_file,required=True)
    nescin_filename = readVariable("nescin_filename","string",regcoil_input_file,required=True)
    
    # Create new directory
    directory = "eval_" + str(self.feval)
    if (not os.path.isdir(directory)):
      os.makedirs(directory)
    os.chdir(directory)

    # Copy nescin file
    src = "../" + nescin_filename
    dst = nescin_filename
    copyfile(src,dst)

    # Copy regcoil_in file
    src = "../" + regcoil_input_file
    dst = regcoil_input_file
    copyfile(src,dst)

    # Edit new nescin file
    new_nescin = nescin_filename + "_" + str(self.feval)
    self.create_nescin(nescin_filename,new_nescin)
    # Remove old nescin file
    os.remove(nescin_filename)

    # Edit regcoil_in file
    with open(regcoil_input_file, 'r') as f:
      inputFile = f.readlines()
    f = open(regcoil_input_file,"w")
    for line in inputFile:
      if namelistLineContains(line,"nescin_filename"):
        line = 'nescin_filename = "'+new_nescin+'"\n'
      if namelistLineContains(line,"wout_filename"):
        new_wout = '../' + wout_filename
        line = 'wout_filename = "'+new_wout+'"\n'
      if (self.general_option > 3):
        if namelistLineContains(line,"current_density_target"):
          line = 'current_density_target = '+str(current_density_target)+'\n'
      f.write(line)
    f.close()

    submitCommand = "regcoil " + regcoil_input_file
    outputFileName = "regcoil_out" + regcoil_input_file[10::]
    g = open(outputFileName,"w")
    try:
      submissionResult = subprocess.call(submitCommand.split(" "),stdout=g)
    except:
      print "ERROR: Unable to submit run "+directory+" for some reason."
      raise
    else:
      if submissionResult==0:
        print "No errors submitting job "+directory
      else:
        print "Nonzero exit code returned when trying to submit job "+directory
        exit
    g.close()

    # Obtain objective function and its derivative
    cdfFileName = outputFileName + ".nc"
    try:
      f = netcdf.netcdf_file(cdfFileName,'r',mmap=False)
    except:
      print "Unable to open "+cdfFileName+" even though this file exists."
      sys.exit(0)
    try:
      dummy = f.variables["K2"][()]
    except:
      print "Unable to read "+cdfFileName+" even though this file exists."
      sys.exit(0)

    exit_code = f.variables["exit_code"][()]
    if (exit_code == 0):
      self.set_dchi2Bdomega(f.variables["dchi2Bdomega"][()][-1])
      self.set_dchi2Kdomega(f.variables["dchi2Kdomega"][()][-1])
      self.set_darea_coildomega(f.variables["darea_coildomega"][()])
      self.area_coil = f.variables["area_coil"][()]
      self.set_dcoil_volumedomega(f.variables["dvolume_coildomega"][()])
      self.set_dcoil_plasma_dist_mindomega(f.variables["dcoil_plasma_dist_mindomega"][()])
      self.set_dcoil_plasma_dist_maxdomega(f.variables["dcoil_plasma_dist_maxdomega"][()])
      self.chi2B = f.variables["chi2_B"][()][-1]
      self.chi2K = f.variables["chi2_K"][()][-1]
      self.coil_volume = f.variables["volume_coil"][()]
      self.coil_plasma_dist_min_lse = f.variables["coil_plasma_dist_min_lse"][()]
      self.coil_plasma_dist_max_lse = f.variables["coil_plasma_dist_max_lse"][()]

      self.evaluateObjectiveFunction()
    
      os.chdir('..')
      self.increment_feval()
      self.evaluated = True
      if (self.general_option > 3):
        self.increased_target_current = False
        self.decreased_target_current = False
        self.current_factor = 0.1
        self.current_density_target = self.current_density_target_init

    else:
      print "Error! Job did not complete."
      if (exit_code == -1): # did not converge in nlambda iterations
        nlambda = f.variables["nlambda"][()]
        new_nlambda = nlambda*2
        print "Trying again with nlambda = " + str(new_nlambda)
        # Edit input file with more nlambda
        os.chdir('..')
        with open(regcoil_input_file, 'r') as f:
          inputFile = f.readlines()
          f = open(regcoil_input_file,"w")
          for line in inputFile:
            if namelistLineContains(line,"nlambda"):
              line = 'nlambda = '+str(new_nlambda)+'\n'
            f.write(line)
          f.close()
        if (self.general_option > 3):
          self.evaluateRegcoil(omegas_sensitivity_new,self.current_density_target)
        else:
          self.evaluateRegcoil(omegas_sensitivity_new)
      # exit_code == -2 or -3 should only happen with general_option > 3
      elif (exit_code == -2): # current density too low or chi2B too high
        if (self.target_option < 9):
          print "Current density too low."
          # Decrease factor of increase/decrease
          if (self.decreased_target_current): # previously tried decreasing target
            self.current_factor = self.current_factor*0.5
            print "current_factor is now: " + str(self.current_factor)
          self.current_density_target = (1.0+self.current_factor)*self.current_density_target
          print "Trying again with current_density_target = " + str(self.current_density_target)
          os.chdir('..')
          self.increased_target_current = True
          self.evaluateRegcoil(omegas_sensitivity_new,self.current_density_target)
        if (self.target_option == 9):
          print "chi2B too high."
          if (self.increased_target_current): # previously tried increasing
            self.current_factor = self.current_factor*0.5
            print "current_factor is now: " + str(self.current_factor)
          self.current_density_target = (1.0-self.current_factor)*self.current_density_target
          print "Trying again with current_density_target = " + str(self.current_density_target)
          os.chdir('..')
          self.decreased_target_current = True
          self.evaluateRegcoil(omegas_sensitivity_new,self.current_density_target)
      elif (exit_code == -3): # current density too high
        if (self.target_option < 9):
          print "Current density too high."
          # Target has been bracketed. Decrease interval.
          if (self.increased_target_current):
            self.current_factor = self.current_factor*0.5
            print "current_factor is now: " + str(self.current_factor)
          self.current_density_target = (1.0-self.current_factor)*self.current_density_target
          print "Trying again with current_density_target = " + str(self.current_density_target)
          os.chdir('..')
          self.decreased_target_current = True
          self.evaluateRegcoil(omegas_sensitivity_new,self.current_density_target)
        else:
          print "chi2_B too low."
          # Target has been bracketed. Decrease interval.
          if (self.decreased_target_current):
            self.current_factor = self.current_factor*0.5
            print "current_factor is now: " + str(self.current_factor)
          self.current_density_target = (1.0+self.current_factor)*self.current_density_target
          print "Trying again with current_density_target = " + str(self.current_density_target)
          os.chdir('..')
          self.increased_target_current = True
          self.evaluateRegcoil(omegas_sensitivity_new,self.current_density_target)
      else:
        sys.exit(0)

  # Creates new nescin file with current Fourier coefficients
  # old_nescin and new_nescin are names of nescin files
  # old_nescin is a copy of the old_nescin file in current directory
  # new_nescin file is desired name for new nescin file with
  # updated Fourier coefficients
  def create_nescin(self,old_nescin,new_nescin):
    currentMode = -1
    newFile = open(new_nescin, "w")
    oldFile = open(old_nescin, "r")

    for line in oldFile:
      if re.match("------ Current Surface",line):
        newFile.write(line)
        lineToWrite = next(oldFile)
        newFile.write(lineToWrite)
        lineToWrite = next(oldFile)
        newFile.write(str(self.nmodes) + "\n")
        lineToWrite = next(oldFile)
        newFile.write(lineToWrite)
        lineToWrite = next(oldFile)
        newFile.write(lineToWrite)
        currentMode = 0
        break
      else:
        newFile.write(line)
  
    oldFile.close()
          
    while(currentMode >= 0):
      lineToWrite = "\t" + str(int(self.xm[currentMode])) + "\t" \
        + str(int(self.xn[currentMode])) + "\t" + str(self.rmncs[currentMode]) \
        + "\t" + str(self.zmnss[currentMode]) + "\t" + str(self.rmnss[currentMode]) \
        + "\t" + str(self.zmncs[currentMode]) + "\n"
      newFile.write(lineToWrite)
      if (currentMode < self.nmodes-1):
        currentMode = currentMode + 1
      else:
        break

    newFile.close()

def evaluateFunctionRegcoil(omegas_sensitivity_new, nescinObject):
  # Check if function has already been evaluated
  if (nescinObject.evaluated == False or not np.array_equal(omegas_sensitivity_new,nescinObject.omegas_sensitivity)):
    if (nescinObject.general_option > 3):
      nescinObject.evaluateRegcoil(omegas_sensitivity_new,nescinObject.current_density_target)
    else:
      nescinObject.evaluateRegcoil(omegas_sensitivity_new)
  return nescinObject.objective_function

def evaluateGradientRegcoil(omegas_sensitivity_new, nescinObject):
  if (nescinObject.evaluated == False or not np.array_equal(omegas_sensitivity_new,nescinObject.omegas_sensitivity)):
    if (nescinObject.general_option > 3):
      nescinObject.evaluateRegcoil(omegas_sensitivity_new,nescinObject.current_density_target)
    else:
      nescinObject.evaluateRegcoil(omegas_sensitivity_new)
  return np.array(nescinObject.dobjective_functiondomegas_sensitivity)

## Testing ##
if __name__ == "__main__":
  nescinObject = coilFourier(int(sys.argv[1]),int(sys.argv[2]),sys.argv[3])
#  print nescinObject.xn
#  print nescinObject.xm
#  print nescinObject.nmax
#  print nescinObject.mmax

  file = "nescin.w7x_winding_surface_from_Drevlak_235"
  path = os.getcwd()
  filename = path + "/" + file
  nescinObject.set_Fourier_from_nescin(filename)
  #print nescinObject.rmncs
  #print nescinObject.zmnss
  #print nescinObject.omegas_sensitivity
  print nescinObject.xn
  print nescinObject.xn_sensitivity
  omegas_old = nescinObject.omegas
  print omegas_old
#  print nescinObject.omegas_sensitivity
  new_omegas = nescinObject.omegas_sensitivity
  for imn in range(0,nescinObject.nmodes_sensitivity):
#    print("m = " + str(nescinObject.xm_sensitivity[imn]))
#    print("n = " + str(nescinObject.xn_sensitivity[imn]))
    if (nescinObject.xm_sensitivity[imn] == 6 and nescinObject.xn_sensitivity[imn] == 3):
      print new_omegas[2*imn]
      print new_omegas[2*imn+1]
      new_omegas[2*imn] = 0
      new_omegas[2*imn+1] = 0
      print "mode obtained!"
  for imn in range(0,nescinObject.nmodes):
    if (nescinObject.xm[imn] == 6 and nescinObject.xn[imn] == 3):
      print "mode obtained in omega!"
      print omegas_old[2*imn]
      print omegas_old[2*imn+1]

  nescinObject.set_omegas_sensitivity(new_omegas)
  print nescinObject.omegas
  nescinObject.compute_spectral_norm()
  print nescinObject.spectral_norm
  print nescinObject.dspectral_normdomegas
