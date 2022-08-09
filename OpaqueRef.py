#!/usr/bin/env python

import sys, time, subprocess

import XenAPI

#het ophalen van de vmname van de stream
VMName = str(sys.argv)[32:-2]

#uncomment onderstaande regel om de variabele te printen ivm testen
#print sys.argv

#inloggen via de xenapi
session = XenAPI.Session('https://localhost')
session.login_with_password('root','virtualsense')

#het opvragen van de opaquereference
opaque = session.xenapi.VM.get_by_name_label(VMName)

#het printen van de opaquereference
print str(opaque)[2:-2]

#het terugparsen van de opaquereference aan het php script-
sys.stderr.write(str(opaque))  
sys.stderr.flush() 
  
