#!/usr/bin/env python
# coding: utf-8

# In[10]:


import os
from ftplib import FTP
from datetime import datetime

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

local_dir = r'.\_site'

for root, dirs, files in os.walk(local_dir):
    for item in files:
        file_path = os.path.join(root, item)

        start_index = file_path.find(".\\_site\\")
        if start_index != -1:
            sub_str = file_path[start_index + len(".\\_site\\"):]
        else:
            print("'.\_site' not found in string")

        last_slash = sub_str.rfind('\\')
        if last_slash != -1:
            sub_dir = sub_str[:last_slash]
        else:
            sub_dir = ''

        ftp_path = f'/public_html/wftdm-docs/{sub_dir}'.replace('\\', '/')
        print('ftp is' + ftp_path)
        try:
            ftp.cwd(ftp_path)
        except:
            # directory does not exist, create it
            ftp.mkd(ftp_path)
            ftp.cwd(ftp_path)
        
        old_items = [item for item in ftp.nlst() if item not in ['.', '..'] and '.' in item]
        if len(old_items) > 0:
            print(f'Deleting old files in {ftp_path}...')
            for item in old_items:
                print(item)
                try:
                    remote_modified_time = ftp.sendcmd(f"MDTM {item}")
                    remote_modified_time = datetime.strptime(remote_modified_time[4:], '%Y%m%d%H%M%S')
                    local_modified_time = datetime.fromtimestamp(os.path.getmtime(os.path.join(local_dir, sub_dir, item)))
                    if remote_modified_time < local_modified_time:
                        ftp.delete(item)
                except:
                    # assume file does not exist if we can't check
                    ftp.delete(item)
        else:
            print(f'No files to delete in {ftp_path}...')
        
        print(f'Uploading new files to {ftp_path}...')
        folder_path = os.path.join(local_dir, sub_dir).replace('\\','/')
        new_items = [os.path.join(folder_path, f) for f in files if os.path.isfile(os.path.join(folder_path, f))]
        for item in new_items:
            print(item)
            try:
                remote_modified_time = ftp.sendcmd(f"MDTM {os.path.basename(item)}")
                remote_modified_time = datetime.strptime(remote_modified_time[4:], '%Y%m%d%H%M%S')
                local_modified_time = datetime.fromtimestamp(os.path.getmtime(item))
                if remote_modified_time < local_modified_time:
                    with open(item, 'rb') as file:
                        ftp.storbinary(f'STOR {os.path.basename(item)}', file)
            except:
                # assume file does not exist if we can't check
                with open(item, 'rb') as file:
                    ftp.storbinary(f'STOR {os.path.basename(item)}', file)

# Close FTP connection
ftp.quit()

print('Upload complete.')


# %%