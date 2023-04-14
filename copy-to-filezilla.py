#!/usr/bin/env python
# coding: utf-8

# In[10]:


import os
from ftplib import FTP

# Set filezilla username, password, and ip hostname variables
un2 = os.environ['FILEZILLA_USERNAME']
pw2 = os.environ['FILEZILLA_PASSWORD']
ip  = os.environ['FILEZILLA_HOSTNAME']

# Debugging output
print("Username:", un2)
print("Password:", pw2)
print("Hostname:", ip)

# connect to the filezilla server
ftp = FTP(ip, timeout=1200)
print(ftp.getwelcome())
ftp.login(user=un2, passwd =pw2)

# Set remote directory to upload to
remote_dir = '/public_html/tdm-docs'
ftp.cwd(remote_dir)

# Set local directory to upload from
local_dir = '_site'

# Iterate through all files in local directory and upload them to remote directory
for filename in os.listdir(local_dir):
    if os.path.isfile(os.path.join(local_dir, filename)):
        with open(os.path.join(local_dir, filename), 'rb') as f:
            ftp.storbinary('STOR ' + filename, f)

# Close FTP connection
ftp.quit()

print('Upload complete.')


# %%
