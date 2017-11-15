import os, time, datetime, sys, shutil

fwdir = os.environ['HOME']
emulation_folder_path= fwdir ##+ '/scripts'
emulation_time_past = time.time() - 30*60 # 30 minutes



def get_files(folder_path):
    folder_files = os.listdir(folder_path)
    for file in folder_files:
        filepath = os.path.join(folder_path, file)
        
        
        if (os.path.exists(filepath)):
            timestamp = os.path.getmtime(filepath)
            if os.path.isfile(filepath) and timestamp < time_past :
                print filepath
            if os.path.isdir(filepath) and timestamp < time_past :
                print filepath     
 
 
def main():
    get_files(folder_path)


if __name__ == "__main__":
    main()
    
   