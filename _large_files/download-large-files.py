import os
import gdown

# INSTRUCTIONS
# put the large files in this directory on google drive: https://drive.google.com/drive/folders/1dM1S724CtgTI_d2Kr6R5LpZvopW4fL8l
# following the instructions in the link in order to create the download url: https://sites.google.com/site/gdocs2direct/
# add the file id from the download url and update the destination below

# List of files to download
file_list = [
    # v900
    {"file_id": "1ChQYUUHuXnnBqoqmpBQJC79mhpekWVxG", "destination": "D:/GitHub/TDM-Documentation/_large_files/v900/5_FinalNetSkims/Skm_AM.omx"},
    {"file_id": "1nreWAS3Pyklh9L0obkCy5hMJdBwJ74GW", "destination": "D:/GitHub/TDM-Documentation/_large_files/v900/5_FinalNetSkims/Skm_MD.omx"},
    {"file_id": "146hbpMAPSB_M6j_EkHyxLmk2j-G3lNpz", "destination": "D:/GitHub/TDM-Documentation/_large_files/v900/5_FinalNetSkims/Skm_PM.omx"},
    {"file_id": "1S4jnNU_nnCWAyWaNViqAEyAAexvLJmGh", "destination": "D:/GitHub/TDM-Documentation/_large_files/v900/5_FinalNetSkims/Skm_EV.omx"},
    {"file_id": "1Eu9z-_wVRrU4h4yUZdZUHr0nC7CedU_v", "destination": "D:/GitHub/TDM-Documentation/_large_files/v900/5_FinalNetSkims/Skm_DY.omx"},
    # v901
    {"file_id": "1ZFpwxwQ2acIshpUWN3BGaKDt3_fXIDom", "destination": "D:/GitHub/TDM-Documentation/_large_files/v901/5_FinalNetSkims/Skm_AM.omx"},
    {"file_id": "1W7VUqWaYmiYHrn9ora6GBPYV02jEUsKU", "destination": "D:/GitHub/TDM-Documentation/_large_files/v901/5_FinalNetSkims/Skm_MD.omx"},
    {"file_id": "19dmLJTRCeson7jXDhjUN0Rx3mptC52IS", "destination": "D:/GitHub/TDM-Documentation/_large_files/v901/5_FinalNetSkims/Skm_PM.omx"},
    {"file_id": "12hlu553SL2CP6s5Y7XRFuC19c3jV2BmQ", "destination": "D:/GitHub/TDM-Documentation/_large_files/v901/5_FinalNetSkims/Skm_EV.omx"},
    # v902
    {"file_id": "1bsEkl75vhhtZwpKpAZI53ecWR8vUPf1f", "destination": "D:/GitHub/TDM-Documentation/_large_files/v902/5_FinalNetSkims/Skm_AM.omx"},
    {"file_id": "16QviQTBegYpUOGgrl4D0nRY-RxAH_wcQ", "destination": "D:/GitHub/TDM-Documentation/_large_files/v902/5_FinalNetSkims/Skm_MD.omx"},
    {"file_id": "1WcbOoQoWLE-ME-NWC6dI2UPwFrKfXxoR", "destination": "D:/GitHub/TDM-Documentation/_large_files/v902/5_FinalNetSkims/Skm_PM.omx"},
    {"file_id": "1RPDsPT0XKNAuWDtPnSEeoXX8eaS-PdlG", "destination": "D:/GitHub/TDM-Documentation/_large_files/v902/5_FinalNetSkims/Skm_EV.omx"}
]

def download_file_from_google_drive(file_id, destination):
    url = f"https://drive.google.com/uc?id={file_id}"
    gdown.download(url, destination, quiet=False)

def download_files(file_list):
    for file_info in file_list:
        file_id = file_info["file_id"]
        destination = file_info["destination"]
        # Ensure the directory exists
        directory = os.path.dirname(destination)
        if not os.path.exists(directory):
            os.makedirs(directory)
        
        # Remove the file if it already exists
        if os.path.exists(destination):
            os.remove(destination)
        
        print(f"Downloading file {file_id} to {destination}...")
        download_file_from_google_drive(file_id, destination)
        print(f"Downloaded file {file_id} to {destination}.")

download_files(file_list)
